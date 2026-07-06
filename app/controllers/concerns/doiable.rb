module Doiable
  extend ActiveSupport::Concern
  include ApiAuthenticatable

  included do
    def extract_url(doi: nil, data: nil)
      hsh = data.split("\n").map do |line| 
        arr = line.to_s.split("=", 2)
        arr << "value" if arr.length < 2
        arr
      end.to_h

      fail IdentifierError, "param 'doi' required" unless hsh["doi"].present?
      fail IdentifierError, "doi parameter does not match doi of resource" if doi.present? && CGI.unescape(hsh["doi"].strip).casecmp(doi) != 0
      
      doi = CGI.unescape(hsh["doi"].strip) unless doi.present?
      fail AbstractController::ActionNotFound unless doi.present?
      
      fail IdentifierError, "param 'url' required" unless hsh["url"].present?

      [doi, CGI.unescape(hsh["url"].strip)]
    end
  end

  module ClassMethods
    require "uri"

    def put_doi(doi, options={})
      with_maremma_auth(options) do |auth|
        return OpenStruct.new(body: { "errors" => [{ "title" => "Not a valid HTTP(S) or FTP URL" }] }) unless /\A(http|https|ftp):\/\/[\S]+/.match(options[:url])
      
        data = {
          "data" => {
            "type" => "dois",
            "attributes"=> {
              "url" => options[:url],
              "should_validate" => "true",
              "source" => "mds",
              "event" => "publish"
            }
          }
        }

        relationships = client_relationship(auth)
        data["data"]["relationships"] = relationships if relationships

        url = "#{ENV['API_URL']}/dois/#{doi}"
        Maremma.put(url, content_type: 'application/vnd.api+json', data: data.to_json, **auth)
      end
    end

    def get_doi(doi, options={})
      with_maremma_auth(options) do |auth|
        url = "#{ENV['API_URL']}/dois/#{doi}/get-url"
        Maremma.get(url, **auth)
      end
    end

    def delete_doi(doi, options={})
      with_maremma_auth(options) do |auth|
        url = "#{ENV['API_URL']}/dois/#{doi}"
        Maremma.delete(url, **auth)
      end
    end

    def get_dois(options={})
      with_maremma_auth(options) do |auth|
        url = "#{ENV['API_URL']}/dois/get-dois"
        Maremma.get(url, **auth)
      end
    end
  end
end