module Metadatable
  extend ActiveSupport::Concern

  module ClassMethods
    def get_metadata(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{api_url}/#{doi}"
      Maremma.get(url, accept: "application/vnd.datacite.datacite+xml", username: options[:username], password: options[:password], raw: true)
    end

    
    def create_metadata(data, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      doc = Nokogiri::XML(data, nil, 'UTF-8', &:noblanks)
      doi = doc.at_css("identifier").content
      
      attributes = {
        "xml" => ::Base64.strict_encode64(data) }

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
      Maremma.put(url, content_type: 'application/vnd.api+json', data: data.to_json, username: options[:username], password: options[:password], raw: true)
    end

    def delete_metadata(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      attributes = {
        "is-active" => false }

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
      Maremma.patch(url, content_type: 'application/vnd.api+json', data: data.to_json, username: options[:username], password: options[:password], raw: true)
    end

    def api_url
      Rails.env.production? ? 'https://app.datacite.org' : 'https://app.test.datacite.org' 
    end
  end
end