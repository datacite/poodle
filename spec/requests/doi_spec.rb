require 'rails_helper'

describe "dois", type: :request, vcr: true do
  let(:credentials) { ::Base64.strict_encode64("#{ENV['MDS_USERNAME']}:#{ENV['MDS_PASSWORD']}") }
  let(:headers) { {'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

  describe '/doi', type: :request do
    it "get all dois" do
      get '/doi', nil, headers

      expect(last_response.status).to eq(200)
      dois = last_response.body.split("\n")
      expect(dois.length).to eq(24)
      expect(dois.last).to eq("10.5438/MCNV-GA6N")
    end
  end

  describe '/doi/10.14454/05MB-Q396', type: :request do
    let(:doi) { "10.14454/05MB-Q396" }
    let(:data) { "doi=10.14454/05MB-Q396\nurl=https://www.datacite.org/" }

    # it "register url for doi" do
    #   headers = { 'HTTP_AUTHORIZATION' => 'Basic ' + credentials, 'CONTENT_TYPE' => "text/plain;charset=UTF-8" }
    #   put "/doi/#{doi}", data, headers

    #   expect(last_response.status).to eq(200)
    #   expect(last_response.body).to eq("https://blog.datacite.org/")
    # end

    it "get url for doi" do
      get "/doi/#{doi}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("https://blog.datacite.org/")
    end
  end

  describe '/doi/10.5438/0012', type: :request do
    let(:doi) { "10.5438/0012" }

    it "get url for doi not found" do
      get "/doi/#{doi}", nil, headers

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("DOI not found")
    end
  end

  describe '/doi/10.1371/journal.pbio.2001414', type: :request do
    let(:doi) { "10.1371/journal.pbio.2001414" }

    it "get url for doi not from DataCite" do
      get "/doi/#{doi}", nil, headers

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("DOI not found")
    end
  end
end