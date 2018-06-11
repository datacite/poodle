module Updateable
  extend ActiveSupport::Concern

  require "bolognese"

  included do
    include Bolognese::DoiUtils

    def create_record(username: nil, password: nil)
      upsert_record(username: username, password: password, action: "create")
    end
  
    def update_record(username: nil, password: nil)
      upsert_record(username: username, password: password, action: "update")
    end
  
    def upsert_record(username: nil, password: nil, action: nil)
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless username.present? && password.present?

      # update doi status
      if target_status == "reserved" || doi.start_with?("10.5072") then
        event = "start"
      elsif target_status == "unavailable"
        event = "hide"
      else
        event = "publish"
      end
  
      xml = input.present? ? Base64.strict_encode64(input) : nil
  
      attributes = {
        doi: doi,
        url: target,
        xml: xml,
        event: event,
        reason: reason }

      attributes.except!("doi") if action == "update"

      data = {
        "data" => {
          "type" => "dois",
          "attributes" => attributes,
          "relationships"=> {
            "client"=>  {
              "data"=> {
                "type"=> "clients",
                "id"=> username
              }
            }
          }
        }
      }

      if action == "create"
        url = "#{ENV['APP_URL']}/dois"
        response = Maremma.post(url, content_type: 'application/vnd.api+json', data: data.to_json, username: username, password: password)
      else
        url = "#{ENV['APP_URL']}/dois/#{doi}"
        response = Maremma.put(url, content_type: 'application/vnd.api+json', data: data.to_json, username: username, password: password)
      end
  
      raise CanCan::AccessDenied if response.status == 401
      error_message(response).presence && return
  
      attributes = response.body.to_h.dig("data", "attributes").to_h
      self.state = attributes.fetch("state", "findable")
      self.created = attributes.fetch("registered", nil)
      self.updated = attributes.fetch("updated", nil)
      self.target = attributes.fetch("url", nil)
      self.reason = attributes.fetch("reason", nil)

      # fetch updated input from content negotiation
      response = Work.get_doi_by_content_type(doi: doi, profile: format)
      self.input = response.body["data"]
  
      message = { "success" => doi_with_protocol,
                  "_status" => status,
                  "_target" => target,
                  format => input,
                  "_profile" => format }.to_anvl
  
      [message, 200]
    end

    def delete_record(username: nil, password: nil)
      return OpenStruct.new(body: { "errors" => [{ "title" => "Username or password missing" }] }) unless username.present? && password.present?

      url = "#{ENV['APP_URL']}/dois/#{doi}"
      response = Maremma.delete(url, content_type: 'application/vnd.api+json', username: username, password: password)

      raise CanCan::AccessDenied if response.status == 401
      error_message(response).presence && return
  
      message = { "success" => doi_with_protocol,
                  "_target" => target,
                  format => input,
                  "_profile" => format }.to_anvl
  
      [message, 200]
    end

    def error_message(response)
      unless [200, 201, 204].include?(response.status)
        [response.body.to_h.fetch("errors", "").inspect, response.status]
      end
    end
  end
end