module Metadatable
  extend ActiveSupport::Concern

  require 'bolognese'
  require 'securerandom'
  require 'base32/url'

  UPPER_LIMIT = 1073741823

  included do
    # find or generate DOI in params, xml, or generate random string
    def extract_doi(str, options={})
      doi = validate_doi(str)
      return doi if doi.present?

      doi = doi_from_xml(str, options)
      return doi if doi.present?

      doi = generate_unique_doi(str, options)
      return doi if doi.present?

      fail AbstractController::ActionNotFound
    end

    def doi_from_xml(str, options={})
      return nil unless Maremma.from_xml(options[:data]).to_h.dig("resource", "xmlns").to_s.start_with?("http://datacite.org/schema/kernel")
      
      doc = Nokogiri::XML(options[:data], nil, 'UTF-8', &:noblanks)
      validate_doi(doc.at_css("identifier").content)
    end

    # make sure we generate a random DOI that is not already used
    # allow seed with number for deterministic minting (e.g. testing)
    def generate_unique_doi(str, options={})
      if options[:number].present?
        doi = generate_random_doi(str, number: options[:number])
        fail IdentifierError, "doi:#{doi} has already been registered" if 
          !MetadataController.get_metadata(doi, options).body.dig("errors")
      else
        duplicate = true
        while duplicate do
          doi = generate_random_doi(str, options)
          duplicate = !Rails.env.test? && !MetadataController.get_metadata(doi, options).body.dig("errors")
        end
      end

      doi
    end

    def generate_random_doi(str, options={})
      prefix = validate_prefix(str)
      return nil unless prefix.present?

      shoulder = str.split("/", 2)[1].to_s
      encode_doi(prefix, shoulder: shoulder, number: options[:number])
    end

    def encode_doi(prefix, options={})
      prefix = validate_prefix(prefix)
      return nil unless prefix.present?

      number = options[:number].to_s.scan(/\d+/).join("").to_i
      number = SecureRandom.random_number(UPPER_LIMIT) unless number > 0
      shoulder = options[:shoulder].to_s
      shoulder += "-" if shoulder.present?
      length = 8
      split = 4
      prefix.to_s + "/" + shoulder + Base32::URL.encode(number, split: split, length: length, checksum: true)
    end  
  end

  module ClassMethods
    include Bolognese::Utils
    include Bolognese::DoiUtils

    def get_metadata(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{api_url}/#{doi}"
      Maremma.get(url, accept: "application/vnd.datacite.datacite+xml", username: options[:username], password: options[:password], raw: true)
    end
    
    def create_metadata(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      xml = options[:data].present? ? ::Base64.strict_encode64(options[:data]) : nil
      
      attributes = {
        "doi" => doi,
        "xml" => xml,
        "event" => "start" }.compact

      data = {
        "data" => {
          "type" => "dois",
          "attributes" => attributes,
          "relationships"=> {
            "client"=>  {
              "data"=> {
                "type"=> "clients",
                "id"=> options[:username]
              }
            }
          }
        }
      }

      url = "#{api_url}/dois/#{doi}"
      Maremma.put(url, content_type: 'application/vnd.api+json', data: data.to_json, username: options[:username], password: options[:password])
    end

    def delete_metadata(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      attributes = {
        "event" => "hide" }

      data = {
        "data" => {
          "type" => "dois",
          "attributes" => attributes,
          "relationships"=> {
            "client"=>  {
              "data"=> {
                "type"=> "clients",
                "id"=> options[:username]
              }
            }
          }
        }
      }

      url = "#{api_url}/dois/#{doi}"
      Maremma.patch(url, content_type: 'application/vnd.api+json', data: data.to_json, username: options[:username], password: options[:password])
    end

    def api_url
      Rails.env.production? ? 'https://app.datacite.org' : 'https://app.test.datacite.org' 
    end
  end
end