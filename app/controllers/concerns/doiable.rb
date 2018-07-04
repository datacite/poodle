module Doiable
  extend ActiveSupport::Concern

  module ClassMethods
    def put_doi(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?
      return OpenStruct.new(body: { "errors" => [{ "title" => "Not a valid HTTP(S) URL" }] }) unless /\Ahttps?:\/\/[\S]+/.match(options[:url])
      
      data = {
        "data" => {
          "type" => "dois",
          "attributes"=> {
            "url" => options[:url],
            "event" => "publish"
          },
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

    def get_doi(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{api_url}/dois/#{doi}/get-url"
      Maremma.get(url, username: options[:username], password: options[:password])
    end

    def delete_doi(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{api_url}/dois/#{doi}"
      Maremma.delete(url, username: options[:username], password: options[:password])
    end

    def get_dois(options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{api_url}/dois/get-dois"
      Maremma.get(url, username: options[:username], password: options[:password])
    end

    def api_url
      Rails.env.production? ? 'https://app.datacite.org' : 'https://app.test.datacite.org' 
    end

    def extract_url(doi: nil, data: nil)
      doi_line, url_line = data.split("\n")

      key, value = doi_line.to_s.split("=", 2)
      fail IdentifierError, "doi parameter does not match doi of resource" if key != "doi" || value.casecmp(doi) != 0
        
      key, value = url_line.to_s.split("=", 2)
      fail IdentifierError, "param 'url' required" if key != "url" || value.blank?

      value
    end
  end
end