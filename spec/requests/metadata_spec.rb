require 'rails_helper'

describe "metadata", type: :request, vcr: true do
  let(:credentials) { ::Base64.strict_encode64("#{ENV['MDS_USERNAME']}:#{ENV['MDS_PASSWORD']}") }

  # describe '/metadata/10.14454/05MB-Q396', type: :request do
  #   let(:doi) { "10.14454/05MB-Q396" }
  #   let(:data) { file_fixture('datacite.xml').read }
  #   let(:headers) { {'CONTENT_TYPE' => 'application/xml;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }
    
  #   it "post metadata for doi" do
  #     post "/metadata/", data, headers

  #     expect(last_response.body).to eq(201)
      
  #     data = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
  #     expect(data.dig("xmlns")).to eq("http://datacite.org/schema/kernel-4")
  #     expect(data.dig("publisher")).to eq("{eLife} Sciences Organisation, Ltd.")
  #     expect(data.dig("titles", "title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
  #   end

  #   it "get metadata for doi" do
  #     get "/metadata/#{doi}", nil, headers

  #     expect(last_response.status).to eq(200)
      
  #     data = Maremma.from_xml(last_response.body).to_h.fetch("resource", {})
  #     expect(data.dig("xmlns")).to eq("http://datacite.org/schema/kernel-4")
  #     expect(data.dig("publisher")).to eq("{eLife} Sciences Organisation, Ltd.")
  #     expect(data.dig("titles", "title")).to eq("Automated quantitative histology reveals vascular morphodynamics during Arabidopsis hypocotyl secondary growth")
  #   end
  # end
end