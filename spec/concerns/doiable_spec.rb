require 'rails_helper'

describe Doiable, vcr: true, order: :defined do
  let(:username) { ENV['MDS_USERNAME'] }
  let(:password) { ENV['MDS_PASSWORD'] }
  let(:options) { { username: username, password: password } }
  let(:doi) { "10.14454/05MB-Q396" }
  let(:url) { "https://blog.datacite.org/" }

  subject { DoisController }
  
  context "put_doi" do
    it 'should register' do
      options = { url: url, username: username, password: password }
      expect(subject.put_doi(doi, options).body.dig("data", "attributes", "url")).to eq(url)
    end

    it 'URL not valid' do
      options = { url: "mailto:support@datacite.org", username: username, password: password }
      expect(subject.put_doi(doi, options).body.dig("errors")).to eq([{"title"=>"Not a valid HTTP(S) URL"}])
    end

    it 'no password' do
      options = { username: username, password: nil }
      expect(subject.put_doi(doi, options).body.dig("errors")).to eq([{"title"=>"Username or password missing"}])
    end
  end

  context "get_doi" do
    it 'should fetch' do
      expect(subject.get_doi(doi, options).body.dig("data", "url")).to eq(url)
    end

    it 'no password' do
      options = { username: username, password: nil }
      expect(subject.get_doi(doi, options).body.dig("errors")).to eq([{"title"=>"Username or password missing"}])
    end
  end

  context "get_dois" do
    it 'should fetch' do
      response = subject.get_dois(options).body
      expect(response.dig("data", "dois").length).to eq(24)
      expect(response.dig("data", "dois").first).to eq("10.14454/05MB-Q396")
    end

    it 'no password' do
      options = { username: username, password: nil }
      expect(subject.get_dois(options).body.dig("errors")).to eq([{"title"=>"Username or password missing"}])
    end
  end

  context "extract_url" do
    it 'should get url' do
      doi = "10.5072/0000-03VC"
      data = "doi=10.5072/0000-03VC\nurl=http://example.org/"
      expect(subject.extract_url(doi: doi, data: data)).to eq("http://example.org/")
    end

    it 'doi does not match' do
      doi = "10.5072/0000-03VC"
      data = "doi=10.5072/AAAA-03VC\nurl=http://example.org/"
      expect { subject.extract_url(doi: doi, data: data) }.to raise_error(IdentifierError, "doi parameter does not match doi of resource")
    end

    it 'no doi key' do
      doi = "10.5072/0000-03VC"
      data = "10.5072/0000-03VC\nurl=http://example.org/"
      expect { subject.extract_url(doi: doi, data: data) }.to raise_error(IdentifierError, "doi parameter does not match doi of resource")
    end

    it 'no url key' do
      doi = "10.5072/0000-03VC"
      data = "doi=10.5072/0000-03VC\nhttp://example.org/"
      expect { subject.extract_url(doi: doi, data: data) }.to raise_error(IdentifierError, "param 'url' required")
    end

    it 'no url' do
      doi = "10.5072/0000-03VC"
      data = "doi=10.5072/0000-03VC"
      expect { subject.extract_url(doi: doi, data: data) }.to raise_error(IdentifierError, "param 'url' required")
    end
  end
end