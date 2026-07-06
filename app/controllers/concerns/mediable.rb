module Mediable
  extend ActiveSupport::Concern
  include ApiAuthenticatable

  module ClassMethods
    def create_media(doi, options={})
      with_maremma_auth(options) do |auth|
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

        url = "#{ENV['API_URL']}/dois/#{doi}/media"
        Maremma.post(url, content_type: 'application/vnd.api+json', data: data.to_json, **auth)
      end
    end

    def list_media(doi, options={})
      with_maremma_auth(options) do |auth|
        url = "#{ENV['API_URL']}/dois/#{doi}/media"
        response = Maremma.get(url, content_type: 'application/vnd.api+json', **auth)
        return response unless response.body["data"].present?
      
        response.body["data"] = Array.wrap(response.body["data"]).map do |m|
          "#{m.dig("attributes", "mediaType").to_s}=#{m.dig("attributes", "url").to_s}"
        end.join("\n")
        response
      end
    end

    def get_media(doi, id, options={})
      with_maremma_auth(options) do |auth|
        url = "#{ENV['API_URL']}/dois/#{doi}/media/#{id}"
        response = Maremma.get(url, content_type: 'application/vnd.api+json', **auth)
        return response unless response.body["data"].present?

        m = response.body["data"]
        response.body["data"] = "#{m.dig("attributes", "mediaType").to_s}=#{m.dig("attributes", "url").to_s}"
        response
      end
    end

    def delete_media(doi, id, options={})
      with_maremma_auth(options) do |auth|
        url = "#{ENV['API_URL']}/dois/#{doi}/media/#{id}"
        Maremma.delete(url, content_type: 'application/vnd.api+json', **auth)
      end
    end
  end
end