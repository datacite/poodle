require "rails_helper"

describe Metadatable, vcr: true, order: :defined do
  let(:username) { ENV["MDS_USERNAME"] }
  let(:password) { ENV["MDS_PASSWORD"] }
  let(:options) { { username: username, password: password } }
  let(:doi) { "10.5438/08a0-3f64" }
  let(:url) { "https://blog.datacite.org/" }
  let(:data) { file_fixture("datacite.xml").read }
  let(:datav3) { file_fixture("datacite-v3.xml").read }
  let(:datav3a) { file_fixture("datacite-v3a.xml").read }
  let(:datav4a) { file_fixture("datacite-v4a.xml").read }
  let(:doiv3) { "10.14454/0000-v3" }
  let(:doiv3a) { "10.14454/0000-0003" }
  let(:doiv4a) { "10.14454/0000-0003" }
  
  context "versions" do
    subject { MetadataController }

    it "should not register invalid version of metadata" do
      options = { data: datav3, username: username, password: password }
      response = subject.create_metadata(doiv3, options)
      expect(response.status).to eq(422)
      expect(response.body.dig("errors")).to eq([{"status"=>422, "title"=>"DOI 10.14454/0000-v3: Schema http://datacite.org/schema/kernel-3 is no longer supported"}])
    end

    it "should get v3 metadata and update registered metadata as v4" do
      options = { username: username, password: password }
      expect(subject.get_metadata(doiv3a, options).body.dig("data")).to eq(datav3a.strip)
 
      options = { data: datav4a, username: username, password: password }
      response = subject.create_metadata(doiv3a, options)
      expect(response.status).to eq(200)
      expect(::Base64.decode64(response.body.dig("data", "attributes", "xml"))).to eq(datav4a.strip)
    end

  end

  context "class_methods" do
    subject { MetadataController }

    context "create_metadata" do
      it "should register metadata" do
        options = { data: data, username: username, password: password }
        response = subject.create_metadata(doi, options)
        expect(response.status).to eq(201)
        expect(::Base64.decode64(response.body.dig("data", "attributes", "xml"))).to eq(data.strip)
        expect(response.body.dig("data", "attributes", "state")).to eq("draft")
        expect(response.body.dig("data", "attributes", "isActive")).to eq(false)
      end

      it "should get" do
        options = { username: username, password: password }
        expect(subject.get_metadata(doi, options).body.dig("data")).to eq(data.strip)
      end

      it "should register doi" do
        options = { url: url, username: username, password: password }
        response = DoisController.put_doi(doi, options)
        expect(response.body.dig("data", "attributes", "url")).to eq(url)
        expect(response.body.dig("data", "attributes", "state")).to eq("findable")
        expect(response.body.dig("data", "attributes", "isActive")).to eq(true)
      end

      it "should delete metadata" do
        options = { username: username, password: password }
        response = subject.delete_metadata(doi, options)
        expect(response.status).to eq(200)
        expect(response.body.dig("data", "attributes", "state")).to eq("registered")
        expect(response.body.dig("data", "attributes", "isActive")).to eq(false)
      end

      it "should re-register doi" do
        options = { url: url, username: username, password: password }
        response = DoisController.put_doi(doi, options)
        expect(response.body.dig("data", "attributes", "url")).to eq(url)
        expect(response.body.dig("data", "attributes", "state")).to eq("findable")
        expect(response.body.dig("data", "attributes", "isActive")).to eq(true)
      end
    end

    # context "create_metadata invalid utf-8" do
    #   let(:doi) { "10.5072/aa01-pxxrkq" }

    #   it "should register" do
    #     data = file_fixture("delft.xml").read
    #     options = { data: data, username: username, password: password }
    #     response = subject.create_metadata(doi, options)
    #     expect(response.status).to eq(201)
    #     expect(::Base64.decode64(response.body.dig("data", "attributes", "xml"))).to eq(data.strip)
    #   end

    #   it "should delete" do
    #     options = { username: username, password: password }
    #     response = DoisController.delete_doi(doi, options)
    #     expect(response.status).to eq(204)
    #     expect(response.body["data"]).to be_blank
    #   end
    # end

    context "create_metadata invalid" do
      let(:doi) { "10.5072/tuprints-dev.ulb.tu-darmstadt.de.10007357" }

      it "should not register" do
        data = file_fixture("tu-darmstadt.xml").read
        options = { data: data, username: username, password: password }
        response = subject.create_metadata(doi, options)
        expect(response.status).to eq(422)
        expect(response.body.dig("errors")).to eq([{"status"=>422, "title"=>"Missing child element(s). expected is one of ( {http://datacite.org/schema/kernel-4}publisher, {http://datacite.org/schema/kernel-4}subjects, {http://datacite.org/schema/kernel-4}contributors, {http://datacite.org/schema/kernel-4}dates, {http://datacite.org/schema/kernel-4}language, {http://datacite.org/schema/kernel-4}alternateidentifiers, {http://datacite.org/schema/kernel-4}relatedidentifiers, {http://datacite.org/schema/kernel-4}sizes, {http://datacite.org/schema/kernel-4}formats, {http://datacite.org/schema/kernel-4}version ). at line 2, column 0"}])
      end
    end

    context "create_metadata schema_org" do
      it "should register" do
        data = file_fixture("schema_org.json").read
        options = { data: data, username: username, password: password }
        response = subject.create_metadata(doi, options)
        expect(response.status).to eq(201)

        metadata = Maremma.from_xml(::Base64.decode64(response.body.dig("data", "attributes", "xml"))).fetch("resource", {})
        expect(metadata.dig("titles", "title")).to eq("Eating your own Dog Food")
        expect(metadata.dig("identifier", "__content__")).to eq(doi.upcase)
      end

      it "should delete" do
        options = { username: username, password: password }
        response = DoisController.delete_doi(doi, options)
        expect(response.status).to eq(204)
        expect(response.body["data"]).to be_blank
      end
    end

    context "create_metadata citeproc" do
      it "should register" do
        data = file_fixture("citeproc.json").read
        options = { data: data, username: username, password: password }
        response = subject.create_metadata(doi, options)
        expect(response.status).to eq(201)

        metadata = Maremma.from_xml(::Base64.decode64(response.body.dig("data", "attributes", "xml"))).fetch("resource", {})
        expect(metadata.dig("titles", "title")).to eq("Eating your own Dog Food")
        expect(metadata.dig("identifier", "__content__")).to eq(doi.upcase)
      end

      it "should delete" do
        options = { username: username, password: password }
        response = DoisController.delete_doi(doi, options)
        expect(response.status).to eq(204)
        expect(response.body["data"]).to be_blank
      end
    end
  end

  context "instance methods" do
    subject { MetadataController.new }

    context "validate_prefix" do
      it "should validate" do
        str = "10.5072"
        expect(subject.validate_prefix(str)).to eq("10.5072")
      end

      it "should validate with slash" do
        str = "10.5072/"
        expect(subject.validate_prefix(str)).to eq("10.5072")
      end

      it "should validate with shoulder" do
        str = "10.5072/FK2"
        expect(subject.validate_prefix(str)).to eq("10.5072")
      end

      it "should not validate if not DOI prefix" do
        str = "20.5072"
        expect(subject.validate_prefix(str)).to be_nil
      end
    end

    context "generate_random_doi" do
      it "should generate" do
        str = "10.5072"
        expect(subject.generate_random_doi(str).length).to eq(17)
      end

      it "should generate with seed" do
        str = "10.5072"
        number = 123456
        expect(subject.generate_random_doi(str, number: number)).to eq("10.5072/003r-j076")
      end

      it "should generate with seed checksum" do
        str = "10.5072"
        number = 1234578
        expect(subject.generate_random_doi(str, number: number)).to eq("10.5072/015n-mj18")
      end

      it "should generate with another seed checksum" do
        str = "10.5072"
        number = 1234579
        expect(subject.generate_random_doi(str, number: number)).to eq("10.5072/015n-mk15")
      end

      it "should generate with shoulder" do
        str = "10.5072/fk2"
        number = 123456
        expect(subject.generate_random_doi(str, number: number)).to eq("10.5072/fk2-003r-j076")
      end

      it "should not generate if not DOI prefix" do
        str = "20.5438"
        expect(subject.generate_random_doi(str)).to be_nil
      end
    end

    context "generate_unique_doi" do
      it "should generate", vcr: false do
        str = "10.5072"
        options = { username: username, password: password }
        expect(subject.generate_unique_doi(str, options).length).to eq(17)
      end

      it "should generate with seed" do
        str = "10.5072"
        options = { number: 123456, username: username, password: password }
        expect(subject.generate_unique_doi(str, options)).to eq("10.5072/003r-j076")
      end

      it "should generate with seed checksum" do
        str = "10.5072"
        options = { number: 1234578, username: username, password: password }
        expect(subject.generate_unique_doi(str, options)).to eq("10.5072/015n-mj18")
      end

      it "should generate with shoulder" do
        str = "10.5072/fk2"
        options = { number: 123456, username: username, password: password }
        expect(subject.generate_unique_doi(str, options)).to eq("10.5072/fk2-003r-j076")
      end

      it "should not generate if not DOI prefix" do
        str = "20.5438"
        expect(subject.generate_unique_doi(str)).to be_nil
      end
    end

    context "extract_doi" do
      it "from params" do
        expect(subject.extract_doi(doi)).to eq(doi)
      end

      it "from xml" do
        expect(subject.extract_doi(nil, from: "datacite", data: data)).to eq(doi)
      end

      it "random" do
        prefix = "10.5072"
        number = 1234578
        expect(subject.extract_doi(prefix, number: number)).to eq("10.5072/015n-mj18")
      end

      it "params overwrite xml" do
        doi = "10.5072/236y-qx15"
        expect(subject.extract_doi(doi, data: data)).to eq(doi)
      end

      it "random without doi in xml" do
        data = file_fixture("datacite_tba.xml").read
        prefix = "10.5072"
        number = 1234578
        expect(subject.extract_doi(prefix, data: data, number: number)).to eq("10.5072/015n-mj18")
      end
    end
  end
end