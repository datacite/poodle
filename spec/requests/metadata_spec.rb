require 'rails_helper'

describe "metadata", type: :request, vcr: true, order: :defined do
  let(:credentials) { ::Base64.strict_encode64("#{ENV['MDS_USERNAME']}:#{ENV['MDS_PASSWORD']}") }

  describe '/metadata/10.0144/DUMMY.V0I1.45', type: :request do
    let(:doi_id) { "10.0144/DUMMY.V0I1.45" }
    let(:headers) { {'ACCEPT' => 'application/xml;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

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
    let(:headers) { {'CONTENT_TYPE' => 'application/xml;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.header["Location"]).to eq("https://mds.test.datacite.org/metadata/10.5072/ey2x-5w17")
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)

      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(metadata.dig("identifier", "__content__")).to eq("10.5072/EY2X-5W17")
    end

    it "put metadata doi exists" do
      data = file_fixture('datacite_tba.xml').read

      put "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
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

  describe '/metadata large file', type: :request do
    let(:doi_id) { "10.5072/ab3v-t139" }
    let(:data) { file_fixture('large_file.xml').read }
    let(:headers) { {'CONTENT_TYPE' => 'application/xml;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.header["Location"]).to eq("https://mds.test.datacite.org/metadata/10.5072/ab3v-t139")
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)

      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("A dataset with a large file for testing purpose. Will be a but over 2.5 MB")
      expect(metadata.dig("identifier", "__content__")).to eq("10.5072/AB3V-T139")
    end

    it "delete doi" do
      delete "/doi/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("OK")
    end
  end

  # describe '/metadata no doi', type: :request do
  #   let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

  #   it "get metadata" do
  #     get "/metadata", nil, headers

  #     expect(last_response.status).to eq(204)
  #     expect(last_response.body).to be_blank
  #   end

  #   it "get metadata no authentication" do
  #     get "/metadata"

  #     expect(last_response.status).to eq(401)
  #     expect(last_response.body).to eq("An Authentication object was not found in the SecurityContext")
  #   end

  #   it "get metadata wrong password" do
  #     credentials = ::Base64.strict_encode64("#{ENV['MDS_USERNAME']}:12345")
  #     headers = {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials }

  #     get "/metadata", nil, headers

  #     sexpect(last_response.status).to eq(401)
  #     expect(last_response.body).to eq("An Authentication object was not found in the SecurityContext")
  #   end
  # end

  describe '/metadata doi from xml', type: :request do
    let(:doi_id) { "10.5438/08a0-3f64" }
    let(:data) { file_fixture('datacite.xml').read }
    let(:headers) { {'CONTENT_TYPE' => 'application/xml;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "post metadata for doi application/x-www-form-urlencoded" do
      headers = {'CONTENT_TYPE' => 'application/x-www-form-urlencoded', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials }
      post "/metadata", data, headers

      expect(last_response.status).to eq(415)
      expect(last_response.body).to eq("Content type application/x-www-form-urlencoded is not supported")
    end


    it "post metadata for doi" do
      post "/metadata", data, headers

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

    it "register doi" do
      doi_data = "doi=10.5438/08a0-3f64\nurl=https://www.datacite.org/roadmap.html"

      put "/doi/#{doi_id}", doi_data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK")
    end

    it "put metadata doi findable" do
      data = file_fixture('datacite_tba.xml').read

      put "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end
  end

  describe '/metadata doi from xml no creator', type: :request do
    let(:doi_id) { "10.5072/pure.item_3001051" }
    let(:data) { file_fixture('no_creator.xml').read }
    let(:headers) { {'CONTENT_TYPE' => 'application/xml;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "post metadata for doi" do
      post "/metadata", data, headers

      expect(last_response.status).to eq(400)
      expect(last_response.body).to eq("Missing child element(s). expected is ( {http://datacite.org/schema/kernel-3}creator ). at line 4, column 0")
    end
  end

  describe '/metadata doi from xml mpdl', type: :request do
    let(:data) { file_fixture('mpdl.xml').read }
    let(:headers) { {'CONTENT_TYPE' => 'application/xml;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "post metadata for doi" do
      post "/metadata", data, headers

      expect(last_response.status).to eq(415)
      expect(last_response.body).to eq("Metadata format not recognized")
    end
  end

  describe '/metadata random doi', type: :request do
    let(:doi_id) { "10.5072/003r-j076" }
    let(:data) { file_fixture('datacite_tba.xml').read }
    let(:headers) { {'CONTENT_TYPE' => 'application/xml;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "put metadata for doi" do
      put "/metadata/10.5072?number=123456", data, headers

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
    let(:headers) { {'CONTENT_TYPE' => 'application/xml;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", nil, headers

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
    let(:headers) { {'CONTENT_TYPE' => 'application/vnd.schemaorg.ld+json', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", data, headers

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
    let(:doi_id) { "10.5072/DVN/HSCUNB" }
    let(:data) { "https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/HSCUNB" }
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", data, headers

      expect(last_response.body).to eq(201)
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
    let(:headers) { {'CONTENT_TYPE' => 'application/vnd.citationstyles.csl+json', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", data, headers

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