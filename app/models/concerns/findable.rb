module Findable
  extend ActiveSupport::Concern

  require "bolognese"

  module ClassMethods
    include Bolognese::DoiUtils

    def where(doi: nil, profile: nil)
      response = get_doi(doi)
      return nil unless response.status == 200

      data = response.body["data"]
      target = data.dig('attributes', 'url')
      datacenter = data.dig('relationships', 'client', 'data', 'id')
      state = data.dig('attributes', 'state')
      created = data.dig('attributes', 'registered')
      updated = data.dig('attributes', 'updated')


      input = response.body["data"]

      Doi.new(input: input,
               from: profile,
               doi: doi,
               target: target,
               datacenter: datacenter,
               state: state,
               created: created,
               updated: updated)
    end

    def get_doi(doi)
      return nil unless doi.present?

      url = "#{ENV['APP_URL']}/dois/#{doi}"
      Maremma.get(url, content_type: 'application/vnd.api+json')
    end

    def get_dois(client_id)
      return nil unless client_id.present?

      url = "#{ENV['APP_URL']}/clients/#{client_id}/dois"
      Maremma.get(url, content_type: 'application/vnd.api+json')
    end
  end
end