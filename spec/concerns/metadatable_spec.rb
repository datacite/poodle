require 'rails_helper'

describe Metadatable, vcr: true, order: :defined do
  let(:username) { ENV['MDS_USERNAME'] }
  let(:password) { ENV['MDS_PASSWORD'] }
  let(:options) { { username: username, password: password } }
  let(:doi) { "10.5438/08A0-3F64" }
  let(:data) { file_fixture('datacite.xml').read }

  subject { MetadataController }

  context "create_metadata" do
    it 'should register' do
      options = { data: data, username: username, password: password }
      response = subject.create_metadata(doi, options)
      expect(response.status).to eq(200)
      expect(::Base64.decode64(response.body.dig("data", "attributes", "xml"))).to eq(data.strip)
    end
  end

  context "get_metadata" do
    it 'should get' do
      options = { username: username, password: password }
      expect(subject.get_metadata(doi, options).body.dig("data")).to eq(data.strip)
    end
  end

  context "delete_metadata draft doi" do
    it 'should delete' do
      options = { username: username, password: password }
      response = subject.delete_metadata(doi, options)
      expect(response.status).to eq(200)
      expect(response.body.dig("data", "attributes", "state")).to eq("draft")
    end
  end
end