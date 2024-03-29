require "rails_helper"

describe "metadata", type: :request, vcr: true, order: :defined do
  let(:credentials) { ::Base64.strict_encode64("#{ENV["MDS_USERNAME"]}:#{ENV["MDS_PASSWORD"]}") }

  describe "/metadata/10.0144/DUMMY.V0I1.45", type: :request do
    let(:doi_id) { "10.0144/DUMMY.V0I1.45" }
    let(:headers) { { "ACCEPT" => "application/xml;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)

      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("Wer gehört zu uns? Einwanderungs- und Staatsangehörigkeitspolitiken in Venezuela und in der Dominikanischen Republik")
      expect(metadata.dig("identifier", "__content__")).to eq("10.0144/dummy.v0i1.45")
    end

    it "get metadata no doi" do
      get "/metadata/", nil, headers

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("DOI not found")
    end

    it "get metadata invalid doi" do
      get "/metadata/xxx", nil, headers

      expect(last_response.status).to eq(404)
      expect(last_response.body).to eq("DOI not found")
    end
  end

  describe "/metadata", type: :request do
    let(:doi_id) { "10.5072/ey2x-5w17" }
    let(:data) { file_fixture("datacite.xml").read }
    let(:headers) { { "CONTENT_TYPE" => "application/xml;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.header["Location"]).to eq(ENV["MDS_URL"] + "/metadata/10.5072/ey2x-5w17")
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get doi for doi" do
      get "/doi/#{doi_id}", nil, headers

      expect(last_response.status).to eq(204)
      expect(last_response.body).to be_blank
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)

      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("Eating your own Dog Food")
      expect(metadata.dig("identifier", "__content__")).to eq("10.5072/EY2X-5W17")
    end

    it "put metadata doi exists" do
      data = file_fixture("datacite_tba.xml").read

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

  describe "/metadata large file", type: :request do
    let(:doi_id) { "10.5072/ab3v-t139" }
    let(:data) { file_fixture("large_file.xml").read }
    let(:headers) { { "CONTENT_TYPE" => "application/xml;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", data, headers


      expect(last_response.status).to eq(201)
      expect(last_response.header["Location"]).to eq(ENV["MDS_URL"] + "/metadata/10.5072/ab3v-t139")
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

  # describe "/metadata no doi", type: :request do
  #   let(:headers) { {"CONTENT_TYPE" => "text/plain;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

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
  #     credentials = ::Base64.strict_encode64("#{ENV["MDS_USERNAME"]}:12345")
  #     headers = {"CONTENT_TYPE" => "text/plain;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials }

  #     get "/metadata", nil, headers

  #     sexpect(last_response.status).to eq(401)
  #     expect(last_response.body).to eq("An Authentication object was not found in the SecurityContext")
  #   end
  # end

  describe "/metadata doi from xml", type: :request do
    let(:doi_id) { "10.5438/08a0-3f64" }
    let(:data) { file_fixture("datacite.xml").read }
    let(:headers) { {"CONTENT_TYPE" => "application/xml;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

    it "post metadata for doi application/x-www-form-urlencoded" do
      headers = { "CONTENT_TYPE" => "application/x-www-form-urlencoded", "HTTP_AUTHORIZATION" => "Basic " + credentials }
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
      data = file_fixture("datacite_tba.xml").read

      put "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end
  end

  describe "/metadata doi from xml namespaced", type: :request do
    let(:doi_id) { "10.14454/at5e-0s42" }
    let(:data) { file_fixture("datacitens.xml").read }
    let(:headers) { { "CONTENT_TYPE" => "application/xml;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

    it "post metadata for doi" do
      post "/metadata", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end
  end

  # describe "/metadata doi from xml no creator", type: :request do
  #   let(:doi_id) { "10.5072/pure.item_3001051" }
  #   let(:data) { file_fixture("no_creator.xml").read }
  #   let(:headers) { {"CONTENT_TYPE" => "application/xml;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

  #   it "post metadata for doi" do
  #     post "/metadata", data, headers

  #     expect(last_response.status).to eq(422)
  #     expect(last_response.body).to eq("Missing child element(s). expected is ( {http://datacite.org/schema/kernel-3}creator ). at line 4, column 0")
  #   end
  # end

  describe "/metadata doi from xml mpdl", type: :request do
    let(:data) { file_fixture("mpdl.xml").read }
    let(:headers) { { "CONTENT_TYPE" => "application/xml;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

    it "post metadata for doi" do
      post "/metadata", data, headers

      expect(last_response.status).to eq(415)
      expect(last_response.body).to eq("Metadata format not recognized")
    end
  end

  describe "/metadata random doi", type: :request do
    let(:doi_id) { "10.5072/003r-j076" }
    let(:data) { file_fixture("datacite_tba.xml").read }
    let(:headers) { { "CONTENT_TYPE" => "application/xml;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

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

  context "no metadata", type: :request do
    let(:doi_id) { "10.5072/236y-qx15" }
    let(:headers) { { "CONTENT_TYPE" => "application/xml;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(422)
      expect(last_response.body).to eq("Can't be blank")
    end

    # it "get metadata for doi" do
    #   get "/metadata/#{doi_id}", nil, headers

    #   expect(last_response.status).to eq(200)

    #   doc = Nokogiri::XML(last_response.body, nil, "UTF-8", &:noblanks)
    #   expect(doc.at_css("identifier").content).to eq("10.5072/236Y-QX15")
    #   expect(doc.at_css("titles").content).to be_blank
    #   expect(doc.at_css("creators").content).to be_blank
    #   expect(doc.at_css("publisher").content).to be_blank
    #   expect(doc.at_css("publicationYear").content).to be_blank
    # end

    # it "delete doi" do
    #   delete "/doi/#{doi_id}", nil, headers

    #   expect(last_response.status).to eq(200)
    #   expect(last_response.body).to eq("OK")
    # end
  end

  context "metadata schema_org", type: :request do
    let(:doi_id) { "10.5072/x86n-nm18" }
    let(:data) { file_fixture("schema_org.json").read }
    let(:headers) { {"CONTENT_TYPE" => "application/vnd.schemaorg.ld+json", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

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

  # context "metadata schema_org as url", type: :request do
  #   let(:doi_id) { "10.5072/DVN/HSCUNZZ" }
  #   let(:data) { "https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/HSCUNB" }
  #   let(:headers) { {"CONTENT_TYPE" => "text/plain;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

  #   it "put metadata for doi" do
  #     put "/metadata/#{doi_id}", data, headers

  #     expect(last_response.body).to eq("OK (#{doi_id.upcase})")
  #     expect(last_response.status).to eq(201)
  #   end

  #   it "get metadata for doi" do
  #     get "/metadata/#{doi_id}", nil, headers

  #     expect(last_response.status).to eq(200)

  #     metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
  #     expect(metadata.dig("titles", "title")).to eq("Replication Data for: Exponential Random Graph Modelling to analyze interactions in participatory practices of place branding.")
  #     expect(metadata.dig("identifier", "__content__")).to eq(doi_id.upcase)
  #   end

  #   it "delete doi" do
  #     delete "/doi/#{doi_id}", nil, headers

  #     expect(last_response.status).to eq(200)
  #     expect(last_response.body).to eq("OK")
  #   end
  # end

  context "metadata citeproc", type: :request do
    let(:doi_id) { "10.5072/ey8x-9f93" }
    let(:data) { file_fixture("citeproc.json").read }
    let(:headers) { {"CONTENT_TYPE" => "application/vnd.citationstyles.csl+json", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

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

  describe "/doi/10.14454/aabbcc11", type: :request do
    let(:doi_id) { "10.14454/aabbcc11" }
    let(:data) { file_fixture("testdoi.xml").read }
    let(:headers) { { "HTTP_AUTHORIZATION" => "Basic " + credentials, "CONTENT_TYPE" => "text/plain;charset=UTF-8" } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "put metadata for doi" do
      post "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "post metadata for doi" do
      post "/metadata", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end
  end

  describe "metadata 4.4", type: :request do
    let(:doi_id) { "10.80225/fdsrf-232" }
    let(:data) { file_fixture("datacite-example-full-v4.4.xml").read }
    let(:headers) { { "CONTENT_TYPE" => "application/xml;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)

      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("subjects", "subject", "classificationCode")).to eq("000")
      expect(metadata.dig("relatedItems", "relatedItem")).to eq(
        {
          "firstPage" => "249",
          "lastPage" => "264",
          "publicationYear" => "2018",
          "relatedItemIdentifier" =>
            { "__content__" => "10.1016/j.physletb.2017.11.044",
            "relatedItemIdentifierType" => "DOI" },
          "relatedItemType" => "Journal",
          "relationType" => "IsPublishedIn",
          "titles" => { "title" => "Physics letters / B" },
          "volume" => "776"
        }
      )
    end

    it "register doi" do
      doi_data = "doi=#{doi_id}\nurl=https://www.example.com/example"

      put "/doi/#{doi_id}", doi_data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK")
    end

  end

  describe "metadata 4.5", type: :request do
    let(:doi_id) { "10.80225/dcmd-v45p0t0" }
    let(:data) { file_fixture("datacite-example-full-v4.5.xml").read }
    let(:headers) { { "CONTENT_TYPE" => "application/xml;charset=UTF-8", "HTTP_AUTHORIZATION" => "Basic " + credentials } }

    it "put metadata for doi" do
      put "/metadata/#{doi_id}", data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK (#{doi_id.upcase})")
    end

    it "get metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(200)

      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("subjects", "subject", "classificationCode")).to eq("000")
      expect(metadata.dig("resourceType", "resourceTypeGeneral")).to eq("StudyRegistration")
      expect(metadata.dig("relatedItems", "relatedItem")).to eq(
        {
          "firstPage" => "249",
          "lastPage" => "264",
          "publicationYear" => "2018",
          "relatedItemIdentifier" =>
            { "__content__" => "10.1016/j.physletb.2017.11.044",
              "relatedItemIdentifierType" => "DOI" },
          "relatedItemType" => "Instrument",
          "relationType" => "IsPublishedIn",
          "titles" => { "title" => "Physics letters / B" },
          "volume" => "776"
        }
      )
      expect(metadata.dig("publisher")).to eq(
        {
          "__content__" => "Silly Walks Publishing, LLC",
          "publisherIdentifier" => "https://ror.org/04z8jg394",
          "publisherIdentifierScheme" => "ROR",
          "schemeURI" => "https://ror.org/",
          "xml:lang" => "en",
        }
      )
    end

    it "register doi" do
      doi_data = "doi=#{doi_id}\nurl=https://www.example.com/example"

      put "/doi/#{doi_id}", doi_data, headers

      expect(last_response.status).to eq(201)
      expect(last_response.body).to eq("OK")
    end

  end
end
