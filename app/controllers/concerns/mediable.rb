module Mediable
  extend ActiveSupport::Concern

  module ClassMethods
    def post_media(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?
      return OpenStruct.new(body: { "errors" => [{ "title" => "Media type and URL missing" }] }) unless options[:data].present?
      
      media_type, url = options[:data].split("=")

      data = {
        "data" => {
          "type" => "media",
          "attributes"=> {
        	  "media-type" => media_type,
            "url" => url
          }
        }
      }

      url = "#{api_url}/dois/#{doi}/media"
      Maremma.post(url, content_type: 'application/vnd.api+json', data: data.to_json, username: options[:username], password: options[:password], raw: true)
    end

    def list_media(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{api_url}/dois/#{doi}/media"
      response = Maremma.get(url, content_type: 'application/vnd.api+json', username: options[:username], password: options[:password])
      response.body["data"] = Array.wrap(response.body["data"]).map do |m|
        "#{m.dig("attributes", "media-type").to_s}=#{m.dig("attributes", "url").to_s}"
      end.join("\n")
      response
    end

    def get_media(doi, id, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{api_url}/dois/#{doi}/media/#{id}"
      response = Maremma.get(url, content_type: 'application/vnd.api+json', username: options[:username], password: options[:password])
      media_type = response.body.dig("data, attributes", "media-type")
      url = response.body.dig("data, attributes", "url")
      response.body["data"] = "#{media_type.to_s}=#{url.to_s}"
      response
    end

    def delete_media(doi, id, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{api_url}/dois/#{doi}/media/#{id}"
      response = Maremma.delete(url, content_type: 'application/vnd.api+json', username: options[:username], password: options[:password])
    end

    def api_url
      Rails.env.production? ? 'https://app.datacite.org' : 'https://app.test.datacite.org' 
    end
  end
end