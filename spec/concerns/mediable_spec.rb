require 'rails_helper'

describe Mediable, vcr: true, order: :defined do
  let(:username) { ENV['MDS_USERNAME'] }
  let(:password) { ENV['MDS_PASSWORD'] }
  let(:options) { { username: username, password: password } }
  let(:doi) { "10.14454/05MB-Q396" }
  let(:url) { "https://blog.datacite.org/" }

  subject { MediaController }

  # context "post_media" do
  #   it 'should register' do
  #     options = { url: url, username: username, password: password }
  #     expect(subject.post_media(doi, options).body.dig("data", "attributes", "url")).to eq(url)
  #   end
  # end

  # context "list_media" do
  #   it 'should list' do
  #     options = { username: username, password: password }
  #     expect(subject.list_media(doi, options).body).to eq(2)
  #   end
  # end

  # context "get_media" do
  #   it 'should get' do
  #     id = "1"
  #     options = { username: username, password: password }
  #     expect(subject.get_media(doi, id, options).body).to eq(2)
  #   end
  # end
end