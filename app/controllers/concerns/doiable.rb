module Doiable
  extend ActiveSupport::Concern

  included do
    def extract_url(doi: nil, data: nil)
      hsh = data.split("\n").map do |line| 
        arr = line.to_s.split("=", 2)
        arr << "value" if arr.length < 2
        arr
      end.to_h

      fail IdentifierError, "param 'doi' required" unless hsh["doi"].present?
      fail IdentifierError, "doi parameter does not match doi of resource" if doi.present? && URI.unescape(hsh["doi"].strip).casecmp(doi) != 0
      
      doi = URI.unescape(hsh["doi"].strip) unless doi.present?
      fail AbstractController::ActionNotFound unless doi.present?
      
      fail IdentifierError, "param 'url' required" unless hsh["url"].present?

      [doi, URI.unescape(hsh["url"].strip)]
    end
  end

  module ClassMethods

    require "uri"

    def put_doi(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?
      return OpenStruct.new(body: { "errors" => [{ "title" => "Not a valid HTTP(S) or FTP URL" }] }) unless /\A(http|https|ftp):\/\/[\S]+/.match(options[:url])
      
      data = {
        "data" => {
          "type" => "dois",
          "attributes"=> {
            "url" => options[:url],
            "should_validate" => "true",
            "source" => "mds",
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

      url = "#{ENV['API_URL']}/dois/#{doi}"
      Maremma.put(url, content_type: 'application/vnd.api+json', data: data.to_json, username: options[:username], password: options[:password])
    end

    def get_doi(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{ENV['API_URL']}/dois/#{doi}/get-url"
      Maremma.get(url, username: options[:username], password: options[:password])
    end

    def delete_doi(doi, options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{ENV['API_URL']}/dois/#{doi}"
      Maremma.delete(url, username: options[:username], password: options[:password])
    end

    def get_dois(options={})
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless options[:username].present? && options[:password].present?

      url = "#{ENV['API_URL']}/dois/get-dois"
      Maremma.get(url, username: options[:username], password: options[:password])
    end
  end
end