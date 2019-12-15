require "rails_helper"

describe "dois", type: :request, vcr: true do
  let(:credentials) { ::Base64.strict_encode64("#{ENV["MDS_USERNAME"]}:#{ENV["MDS_PASSWORD"]}") }
  let(:headers) { {"HTTP_AUTHORIZATION" => "Basic " + credentials } }

  describe "authentication", type: :request do
    let(:doi) { "10.14454/05MB-Q396" }

    it "no username and password" do
      get "/doi/#{doi}"

      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq("An Authentication object was not found in the SecurityContext")
    end

    it "wrong password" do
      headers = { "HTTP_AUTHORIZATION" => "Basic " + ::Base64.strict_encode64("#{ENV["MDS_USERNAME"]}:123") }

      get "/doi/#{doi}", nil, headers

      #expect(last_response.status).to eq(401)
      expect(last_response.body).to eq("Bad credentials")
    end
  end

  describe "/doi", type: :request do
    it "get all dois" do
      get "/doi", nil, headers

      expect(last_response.status).to eq(200)
      dois = last_response.body.split("\n")
      expect(dois.length).to eq(440)
      expect(dois.last).to eq("10.5438/ZYJN-KXX9")
    end

    it "no dois" do
      url = "https://api.test.datacite.org/dois/get-dois"
      stub = stub_request(:get, url).to_return(status: 204, headers: { "Content-Type" => "text/plain" }, body: nil)
      get "/doi", nil, headers

      expect(last_response.status).to eq(204)
      expect(last_response.body).to be_blank
    end

    it "get all dois HEAD" do
      head "/doi", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to be_blank
    end

    it "no dois HEAD" do
      url = "https://api.test.datacite.org/dois/get-dois"
      stub = stub_request(:get, url).to_return(status: 204, headers: { "Content-Type" => "text/plain" }, body: nil)
      head "/doi", nil, headers

      expect(last_response.status).to eq(204)
      expect(last_response.body).to be_blank
    end
  end

  describe "/doi", type: :request do
    let(:data) { "doi=10.14454/05MB-Q396\nurl=https://www.datacite.org/roadmap.html" }
    let(:headers) { { "HTTP_AUTHORIZATION" => "Basic " + credentials, "CONTENT_TYPE" => "text/plain;charset=UTF-8" } }

    # it "post dois" do
    #   post "/doi", data, headers

    #   expect(last_response.status).to eq(201)
    #   expect(last_response.body).to eq("OK")
    # end

    # it "register url for doi escaped" do
    #   data = "doi=10.14454%2F05MB-Q396\nurl=https%3A%2F%2Fwww.datacite.org%2Froadmap.html"
    #   post "/doi", data, headers

    #   expect(last_response.status).to eq(201)
    #   expect(last_response.body).to eq("OK")
    # end

    # it "register url with params" do
    #   params = { doi: "10.14454/05MB-Q396", url: "https://www.datacite.org/user-stories.html" }
    #   post "/doi?#{URI.encode_www_form(params)}", nil, headers

    #   expect(last_response.status).to eq(201)
    #   expect(last_response.body).to eq("OK")
    # end

    it "register url no data" do
      post "/doi", nil, headers

      expect(last_response.status).to eq(400)
      expect(last_response.body).to be_blank
    end

    it "register url no doi" do
      data = "url=https://www.datacite.org/"

      post "/doi", data, headers

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq("param 'doi' required")
    end

    it "register url no url" do
      data = "doi=10.14454/05MB-Q396"

      post "/doi", data, headers

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq("param 'url' required")
    end

    # it "register url spaces" do
    #   doi = "10.14454/05mb-q396"
    #   data = "doi= 10.14454/05MB-Q396\nurl= https://www.datacite.org/roadmap.html"

    #   post "/doi", data, headers
    #   expect(last_response.status).to eq(201)
    #   expect(last_response.body).to eq("OK")
    # end
  end

  describe "/doi/10.14454/05MB-Q396", type: :request do
    let(:doi) { "10.14454/05MB-Q396" }
    let(:data) { "doi=10.14454/05MB-Q396\nurl=https://www.datacite.org/roadmap.html" }
    let(:headers) { { "HTTP_AUTHORIZATION" => "Basic " + credentials, "CONTENT_TYPE" => "text/plain;charset=UTF-8" } }

    # it "register url for doi" do
    #   put "/doi/#{doi}", data, headers

    #   expect(last_response.status).to eq(201)
    #   expect(last_response.body).to eq("OK")
    # end

    # it "register url for doi escaped" do
    #   data = "doi=10.14454%2F05MB-Q396\nurl=https%3A%2F%2Fwww.datacite.org%2Froadmap.html"
    #   put "/doi/#{doi}", data, headers

    #   expect(last_response.status).to eq(201)
    #   expect(last_response.body).to eq("OK")
    # end

    it "register url no data" do
      put "/doi/#{doi}", nil, headers

      expect(last_response.status).to eq(400)
      expect(last_response.body).to be_blank
    end

    it "register url no doi" do
      data = "url=https://www.datacite.org/"

      put "/doi/#{doi}", data, headers

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq("param 'doi' required")
    end

    it "register url doi mismatch" do
      data = "doi=10.14454/05MB-QQQQ\nurl=https://www.datacite.org/"

      put "/doi/#{doi}", data, headers

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq("doi parameter does not match doi of resource")
    end

    it "register url no url" do
      data = "doi=10.14454/05MB-Q396"

      put "/doi/#{doi}", data, headers

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq("param 'url' required")
    end

    it "register url spaces" do
      doi = "10.5072/FBFTV0VREUQV"
      data = "doi= 10.5072/FBFTV0VREUQV\nurl= https://identifiers.globus.org/doi:10.5072/FBFTV0VREUQV/landingpage"

      put "/doi/#{doi}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK")

      # delete "/doi/#{doi}", nil, headers

      # expect(last_response.status).to eq(200)
      # expect(last_response.body).to eq("OK")
    end

    it "get url for doi" do
      get "/doi/#{doi}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("https://www.datacite.org/roadmap.html")
    end
  end

  describe "/doi/10.5438/0012", type: :request do
    let(:doi) { "10.5438/0012" }
    let(:data) { "doi=10.5438/0012\nurl=https://www.datacite.org/roadmap.html" }
    let(:headers) { { "HTTP_AUTHORIZATION" => "Basic " + credentials, "CONTENT_TYPE" => "text/plain;charset=UTF-8" } }

    # it "register url for doi not found" do
    #   put "/doi/#{doi}", data, headers

    #   expect(last_response.status).to eq(412)
    #   expect(last_response.body).to eq("You have to register metadata first!")
    # end

    it "get url for doi not found" do
      headers = {"HTTP_AUTHORIZATION" => "Basic " + credentials }
      get "/doi/#{doi}", nil, headers

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("DOI not found")
    end
  end

  describe "/doi/10.1371/journal.pbio.2001414", type: :request do
    let(:doi) { "10.1371/journal.pbio.2001414" }

    it "get url for doi not from DataCite" do
      get "/doi/#{doi}", nil, headers

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("DOI not found")
    end
  end

  describe "/doi/10.5072/rgby-wt03 delete", type: :request do
    let(:doi) { "10.5072/rgby-wt03" }
    let(:username) { ENV["MDS_USERNAME"] }
    let(:password) { ENV["MDS_PASSWORD"] }
    let(:data) { file_fixture("datacite.xml").read }
    let(:options) { { data: data, username: username, password: password } }

    it "delete doi" do
      MetadataController.create_metadata(doi, options)

      delete "/doi/#{doi}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
    end

    # it "not delete findable doi" do
    #   doi = "10.14454/05MB-Q396"
    #   delete "/doi/#{doi}", nil, headers

    #   expect(last_response.status).to eq(405)
    #   expect(last_response.body).to eq("Method not allowed")
    # end
  end
end
