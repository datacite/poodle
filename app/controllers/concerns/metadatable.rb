module Metadatable
  extend ActiveSupport::Concern

  require 'bolognese'
  require 'securerandom'
  require 'base32/url'

  UPPER_LIMIT = 1073741823

  included do
    def find_from_format_by_string(string)
      if Maremma.from_xml(string).to_h.dig("doi_records", "doi_record", "crossref").present?
        "crossref"
      elsif Nokogiri::XML(string, nil, 'UTF-8', &:noblanks).collect_namespaces.find { |k, v| v.start_with?("http://datacite.org/schema/kernel") }  
        "datacite"
      elsif Maremma.from_json(string).to_h.dig("@context").to_s.start_with?("http://schema.org", "https://schema.org")
        "schema_org"
      elsif Maremma.from_json(string).to_h.dig("@context") == ("https://raw.githubusercontent.com/codemeta/codemeta/master/codemeta.jsonld")
        "codemeta"
      elsif Maremma.from_json(string).to_h.dig("schema-version").to_s.start_with?("http://datacite.org/schema/kernel")
        "datacite_json"
      elsif Maremma.from_json(string).to_h.dig("types").present?
        "crosscite"
      elsif Maremma.from_json(string).to_h.dig("issued", "date-parts").present?
        "citeproc"
      elsif string.start_with?("TY  - ")
        "ris"
      elsif BibTeX.parse(string).first
        "bibtex"
      end
    rescue
      nil
    end

    # find or generate DOI in params, xml, or generate random string
    def extract_doi(str, options={})
      doi = validate_doi(str)
      return doi if doi.present?

      if options[:from] == "datacite"
        doi = doi_from_xml(str, options)
        return doi if doi.present?
      end

      doi = generate_unique_doi(str, options)
      return doi
    end

    def doi_from_xml(str, options={})
      doc = Nokogiri::XML(options[:data], nil, 'UTF-8', &:noblanks)
      doc.remove_namespaces!
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
        "validate" => "true",
        "source" => "mds",
        "event" => "publish" }.compact

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
      Rails.env.production? ? 'https://api.datacite.org' : 'https://api.test.datacite.org'
    end
  end
end