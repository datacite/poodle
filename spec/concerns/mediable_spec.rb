require 'rails_helper'

describe Mediable, vcr: true, order: :defined do
  let(:username) { ENV['MDS_USERNAME'] }
  let(:password) { ENV['MDS_PASSWORD'] }
  let(:options) { { username: username, password: password } }
  let(:doi) { "10.14454/05MB-Q396" }
  let(:data) { "application/pdf=https://schema.datacite.org/meta/kernel-4.1/doc/DataCite-MetadataKernel_v4.1.pdf"}
  let(:id) { "0000-0000-0000-n07b" }

  subject { MediaController }

  context "create_media" do
    it 'should register' do
      options = { data: data, username: username, password: password }
      response = subject.create_media(doi, options)
      expect(response.body.dig("data", "id")).to eq(id)
      expect(response.body.dig("data", "attributes", "mediaType")).to eq("application/pdf")
      expect(response.body.dig("data", "attributes", "url")).to eq("https://schema.datacite.org/meta/kernel-4.1/doc/DataCite-MetadataKernel_v4.1.pdf")
    end
  end

  context "list_media" do
    it 'should list' do
      options = { username: username, password: password }
      expect(subject.list_media(doi, options).body.dig("data")).to eq(data)
    end
  end

  context "get_media" do
    it 'should get' do
      options = { username: username, password: password }
      expect(subject.get_media(doi, id, options).body.dig("data")).to eq(data)
    end
  end

  context "delete_media" do
    it 'should delete' do
      options = { username: username, password: password }
      expect(subject.delete_media(doi, id, options).status).to eq(204)
    end
  end
end