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

    it "get metadata for doi restful" do
      get "/doi/#{doi_id}/metadata", nil, headers

      expect(last_response.status).to eq(200)
      
      metadata = Maremma.from_xml(last_response.body).fetch("resource", {})
      expect(metadata.dig("titles", "title")).to eq("Wer gehört zu uns? Einwanderungs- und Staatsangehörigkeitspolitiken in Venezuela und in der Dominikanischen Republik")
      expect(metadata.dig("identifier", "__content__")).to eq("10.0144/dummy.v0i1.45")
    end
  end

  describe '/metadata/10.5072/ey2x-5w17', type: :request do
    let(:doi_id) { "10.5072/ey2x-5w17" }
    let(:data) { file_fixture('datacite.xml').read }
    let(:headers) { {'CONTENT_TYPE' => 'text/plain;charset=UTF-8', 'HTTP_AUTHORIZATION' => 'Basic ' + credentials } }

    it "no metadata for doi" do
      get "/metadata/#{doi_id}", nil, headers

      expect(last_response.status).to eq(404)

      expect(last_response.body).to eq("DOI is unknown to MDS")  
    end

    # it "post metadata for doi" do
    #   post "/metadata/#{doi_id}", data, headers

    #   expect(last_response.status).to eq(200)
    #   expect(last_response.body).to eq("OK")  
    # end

    # it "get metadata for doi" do
    #   get "/metadata/#{doi_id}", nil, headers

    #   expect(last_response.status).to eq(200)
    #   expect(last_response.body).to eq("application/pdf=https://schema.datacite.org/meta/kernel-4.1/doc/DataCite-MetadataKernel_v4.1.pdf")  
    # end

    # it "delete metadata for doi" do
    #   id = "0000-0000-0000-mzxa"
    #   delete "/doi/#{doi_id}/metadata/#{id}", nil, headers

    #   expect(last_response.status).to eq(200)
    #   expect(last_response.body).to eq("OK")  
    # end

    it "post metadata for doi restful" do
      post "/doi/#{doi_id}/metadata", data, headers

      expect(last_response.status).to eq(201)
      #expect(last_response.body).to eq("OK (#{doi_id.upcase})")  
    end

    # it "delete metadata for doi restful" do
    #   id = "0000-0000-0000-mzxb"
    #   delete "/doi/#{doi_id}/metadata/#{id}", nil, headers

    #   expect(last_response.status).to eq(200)
    #   expect(last_response.body).to eq("OK")  
    # end
  end
end