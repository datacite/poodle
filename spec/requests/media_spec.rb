require 'rails_helper'

describe "media", type: :request, vcr: true, order: :defined do
  let(:credentials) { ::Base64.strict_encode64("#{ENV['MDS_USERNAME']}:#{ENV['MDS_PASSWORD']}") }

  describe '/media/10.0144/DUMMY.V0I1.45', type: :request do
    let(:doi_id) { "10.0144/DUMMY.V0I1.45" }
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "get media for doi" do
      get "/media/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)

      expect(last_response.body).to eq("application/pdf=https://vm6lux05.ub.uni-osnabrueck.de/ojs3/index.php/dummy/article/view/45")  
    end

    it "get media for doi restful" do
      get "/doi/#{doi_id}/media", nil, headers

      expect(last_response.status).to eq(200)

      expect(last_response.body).to eq("application/pdf=https://vm6lux05.ub.uni-osnabrueck.de/ojs3/index.php/dummy/article/view/45")  
    end
  end

  describe '/media/10.14454/05MB-Q396', type: :request do
    let(:doi_id) { "10.14454/05MB-Q396" }
    let(:data) { "application/pdf=https://schema.datacite.org/meta/kernel-4.1/doc/DataCite-MetadataKernel_v4.1.pdf"}
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "no media for doi" do
      get "/media/#{doi_id}", nil, headers

      expect(last_response.status).to eq(404)

      expect(last_response.body).to eq("No media for the DOI")  
    end

    it "post media for doi" do
      post "/media/#{doi_id}", data, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")  
    end

    it "get media for doi" do
      get "/media/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("application/pdf=https://schema.datacite.org/meta/kernel-4.1/doc/DataCite-MetadataKernel_v4.1.pdf")  
    end

    it "delete media for doi" do
      id = "0000-0000-0000-n07c"
      delete "/doi/#{doi_id}/media/#{id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")  
    end

    it "post media for doi restful" do
      post "/doi/#{doi_id}/media", data, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")  
    end
  end

  describe '/media/10.5072/xxxxxx', type: :request do
    let(:doi_id) { "10.5072/xxxxxx" }
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "doi not found" do
      get "/media/#{doi_id}", nil, headers

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("DOI is unknown to MDS")  
    end
  end
end