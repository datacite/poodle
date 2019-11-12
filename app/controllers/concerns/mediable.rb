module Mediable
  extend ActiveSupport::Concern

  module ClassMethods
    def create_media(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?
      return OpenStruct.new(body: { "errors" => [{ "title" => "Media type and URL missing" }] }) unless options[:data].present?
      
      media_type, url = options[:data].split("=")

      data = {
        "data" => {
          "type" => "media",
          "attributes"=> {
        	  "mediaType" => media_type,
            "url" => url
          }
        }
      }

      url = "#{api_url}/dois/#{doi}/media"
      Maremma.post(url, content_type: 'application/vnd.api+json', data: data.to_json, username: options[:username], password: options[:password])
    end

    def list_media(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{api_url}/dois/#{doi}/media"
      response = Maremma.get(url, content_type: 'application/vnd.api+json', username: options[:username], password: options[:password])
      return response unless response.body["data"].present?
      
      response.body["data"] = Array.wrap(response.body["data"]).map do |m|
        "#{m.dig("attributes", "mediaType").to_s}=#{m.dig("attributes", "url").to_s}"
      end.join("\n")
      response
    end

    def get_media(doi, id, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{api_url}/dois/#{doi}/media/#{id}"
      response = Maremma.get(url, content_type: 'application/vnd.api+json', username: options[:username], password: options[:password])
      return response unless response.body["data"].present?

      m = response.body["data"]
      response.body["data"] = "#{m.dig("attributes", "mediaType").to_s}=#{m.dig("attributes", "url").to_s}"
      response
    end

    def delete_media(doi, id, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{api_url}/dois/#{doi}/media/#{id}"
      response = Maremma.delete(url, content_type: 'application/vnd.api+json', username: options[:username], password: options[:password])
    end

    def api_url
      if Rails.env.production?
        'https://api.local'
      elsif Rails.env.stage?
        'https://api.test.local'
      else
        'https://api.test.datacite.org'
      end
    end
  end
end