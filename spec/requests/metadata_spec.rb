require 'rails_helper'

describe "metadata", type: :request, vcr: true, order: :defined do
  let(:credentials) { ::Base64.strict_encode64("#{ENV['MDS_USERNAME']}:#{ENV['MDS_PASSWORD']}") }

  describe '/metadata/10.0144/DUMMY.V0I1.45', type: :request do
    let(:doi_id) { "10.0144/DUMMY.V0I1.45" }
    let(:headers) { {'ACCEPT' => 'qpplication/xml;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)

      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("Wer gehört zu uns? Einwanderungs- und Staatsangehörigkeitspolitiken in Venezuela und in der Dominikanischen Republik")
      expect(metadata.dig("identifier", "__content__")).to eq("10.0144/dummy.v0i1.45")
    end
  end

  describe '/metadata', type: :request do
    let(:doi_id) { "10.5072/ey2x-5w17" }
    let(:data) { file_fixture('datacite.xml').read }
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "post metadata for doi" do
      post "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)

      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(metadata.dig("identifier", "__content__")).to eq("10.5072/EY2X-5W17")
    end

    it "delete metadata for doi" do
      delete "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")  
    end

    it "delete doi" do
      delete "/doi/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
    end
  end

  describe '/metadata doi from xml', type: :request do
    let(:doi_id) { "10.5438/08a0-3f64" }
    let(:data) { file_fixture('datacite.xml').read }
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "post metadata for doi" do
      post "/metadata", data, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)

      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(metadata.dig("identifier", "__content__")).to eq(doi_id.upcase)
    end

    it "delete metadata for doi" do
      delete "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")  
    end

    it "delete doi" do
      delete "/doi/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
    end
  end

  describe '/metadata random doi', type: :request do
    let(:doi_id) { "10.5072/003r-j076" }
    let(:data) { file_fixture('datacite_tba.xml').read }
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "post metadata for doi" do
      post "/metadata/10.5072?number=123456", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)

      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(metadata.dig("identifier", "__content__")).to eq(doi_id.upcase)
    end

    it "delete metadata for doi" do
      delete "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")  
    end

    it "delete doi" do
      delete "/doi/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
    end
  end

  context 'no metadata', type: :request do
    let(:doi_id) { "10.5072/236y-qx15" }
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "post metadata for doi" do
      post "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to be_blank
    end

    it "delete doi" do
      delete "/doi/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
    end
  end

  context 'metadata schema_org', type: :request do
    let(:doi_id) { "10.5072/x86n-nm18" }
    let(:data) { file_fixture('schema_org.json').read }
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "post metadata for doi" do
      post "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      
      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(metadata.dig("identifier", "__content__")).to eq(doi_id.upcase)
    end

    it "delete doi" do
      delete "/doi/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
    end
  end

  context 'metadata schema_org as url', type: :request do
    let(:doi_id) { "10.7910/DVN/HSCUNB" }
    let(:data) { "https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/HSCUNB" }
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "post metadata for doi" do
      post "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      
      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("Replication Data for: Exponential Random Graph Modelling to analyze interactions in participatory practices of place branding.")
      expect(metadata.dig("identifier", "__content__")).to eq(doi_id.upcase)
    end

    it "delete doi" do
      delete "/doi/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
    end
  end

  context 'metadata citeproc', type: :request do
    let(:doi_id) { "10.5072/ey8x-9f93" }
    let(:data) { file_fixture('citeproc.json').read }
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "post metadata for doi" do
      post "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      
      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(metadata.dig("identifier", "__content__")).to eq(doi_id.upcase)
    end

    it "delete doi" do
      delete "/doi/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
    end
  end
end