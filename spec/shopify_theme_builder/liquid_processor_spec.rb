# frozen_string_literal: true

require "spec_helper"

RSpec.describe ShopifyThemeBuilder::LiquidProcessor do
  subject { described_class.new(file) }

  let(:file_type) { "block" }
  let(:component_name) { "button" }
  let(:file) { "_folder_to_watch/#{component_name}/#{file_type}.liquid" }

  def file_content(content, tag = nil)
    return "" if content.empty?

    return "\n#{content}\n" if tag.nil?

    "\n{% #{tag} %}\n#{content}\n{% end#{tag} %}\n"
  end

  describe "#process" do
    before do
      allow(Dir).to receive(:glob).and_return([file])
      allow(File).to receive(:exist?).and_return(true)
    end

    context "with wrong liquid file type" do
      let(:file_type) { "unknown" }

      before do
        allow(File).to receive(:read).with(file).and_return("Some content")
      end

      it "logs an error for unsupported liquid file type" do
        spy = double(error: nil)
        allow(Logger).to receive(:new).and_return(spy)

        described_class.new(file).process

        expect(spy).to have_received(:error).with("Skipping unsupported file: #{file}")
      end
    end

    context "with missing liquid file" do
      before do
        allow(Dir).to receive(:glob).and_return([])
      end

      it "logs an error for missing liquid file" do
        spy = double(error: nil)
        allow(Logger).to receive(:new).and_return(spy)

        described_class.new(file).process

        expect(spy).to have_received(:error).with("No liquid file found in #{File.dirname(file)}")
      end
    end

    context "with multiple liquid files" do
      before do
        allow(Dir).to receive(:glob).and_return([file, file.gsub(".liquid", "_duplicate.liquid")])
      end

      it "logs an error for multiple liquid files" do
        spy = double(error: nil)
        allow(Logger).to receive(:new).and_return(spy)

        described_class.new(file).process

        expect(spy).to have_received(:error).with("Multiple liquid files found in #{File.dirname(file)}")
      end
    end

    context "with invalid file name" do
      let(:file) { "_folder_to_watch/#{file_type}.liquid" }

      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it "logs an error for invalid file name" do
        spy = double(error: nil)
        allow(Logger).to receive(:new).and_return(spy)

        described_class.new(file).process

        expect(spy).to have_received(:error).with("Invalid file name for file: #{file}\n\
Probably because the file is directly under the components folder.")
      end
    end

    shared_examples "the liquid processor" do |
      comment_content,
      doc_content,
      liquid_content,
      schema_content,
      css_content,
      js_content
    |
      let(:expected_content) do
        "{% comment %}\
\n------------------------------------------------------------\n\
IMPORTANT: The contents of this file are auto-generated.\n\
Avoid editing this file directly.\n\n\
Compiled from #{file}\n\
------------------------------------------------------------\n\
#{file_content(comment_content)}\
{% endcomment %}\n\
#{
  file_content(doc_content, "doc") +
  file_content(liquid_content) +
  file_content(schema_content, "schema") +
  file_content(css_content, "stylesheet") +
  file_content(js_content, "javascript")
}"
      end

      before do
        allow(File).to receive(:read).with(file).and_return(liquid_content)
        allow(File).to receive(:read).with("_folder_to_watch/#{component_name}/comment.txt").and_return(comment_content)
        allow(File).to receive(:read).with("_folder_to_watch/#{component_name}/doc.txt").and_return(doc_content)
        allow(File).to receive(:read).with("_folder_to_watch/#{component_name}/schema.json").and_return(schema_content)
        allow(File).to receive(:read).with("_folder_to_watch/#{component_name}/style.css").and_return(css_content)
        allow(File).to receive(:read).with("_folder_to_watch/#{component_name}/index.js").and_return(js_content)
        allow(File).to receive(:write)
      end

      it "returns the compiled filename" do
        folder_arr = component_name.split(File::SEPARATOR) -
                     described_class::LIQUID_FILE_TYPES -
                     described_class::LIQUID_FILE_TYPES.map { |type| "#{type}s" }
        compiled_filename = "#{file_type}s/#{folder_arr.join("--")}.liquid"
        expect(subject.process).to eq(compiled_filename)
      end

      it "creates a compiled liquid file with right content" do
        subject.process

        folder_arr = component_name.split(File::SEPARATOR) -
                     described_class::LIQUID_FILE_TYPES -
                     described_class::LIQUID_FILE_TYPES.map { |type| "#{type}s" }
        expect(File).to have_received(:write).with("#{file_type}s/#{folder_arr.join("--")}.liquid", expected_content)
      end
    end

    context "with a complete component (section with all files)" do
      it_behaves_like "the liquid processor",
                      "comment",
                      "doc content",
                      "<div>Button Section</div>",
                      '{ "name": "Button Section" }',
                      ".button { color: red; }",
                      "console.log('Button Section');"
    end

    context "with missing optional files" do
      it_behaves_like "the liquid processor",
                      "",
                      "",
                      "<div>Button Section</div>",
                      '{ "name": "Button Section" }',
                      "",
                      ""
    end

    context "with only liquid file" do
      it_behaves_like "the liquid processor",
                      "",
                      "",
                      "<div>Simple component</div>",
                      "",
                      "",
                      ""
    end

    context "with snippet component" do
      let(:file_type) { "snippet" }

      it_behaves_like "the liquid processor",
                      "",
                      "",
                      "<div>Simple snippet</div>",
                      "",
                      "",
                      ""
    end

    context "with nested component" do
      let(:file_type) { "section" }
      let(:component_name) { "header/main" }
      let(:file) { "_folder_to_watch/#{component_name}/#{file_type}.liquid" }

      it_behaves_like "the liquid processor",
                      "comment",
                      "doc content",
                      "<div>Header Main Section</div>",
                      '{ "name": "Header Main Section" }',
                      ".header-main { color: blue; }",
                      "console.log('Header Main Section');"
    end

    context "with nested component using Shopify folders" do
      let(:file_type) { "section" }
      let(:component_name) { "sections/header/main" }
      let(:file) { "_folder_to_watch/#{component_name}/#{file_type}.liquid" }

      it_behaves_like "the liquid processor",
                      "comment",
                      "doc content",
                      "<div>Header Main Section</div>",
                      '{ "name": "Header Main Section" }',
                      ".header-main { color: blue; }",
                      "console.log('Header Main Section');"
    end

    context "when only liquid file is present" do
      let(:expected_content) do
        "{% comment %}\
\n------------------------------------------------------------\n\
IMPORTANT: The contents of this file are auto-generated.\n\
Avoid editing this file directly.\n\n\
Compiled from #{file}\n\
------------------------------------------------------------\n\
{% endcomment %}\n\
\n<button>Click me</button>\n"
      end

      before do
        allow(File).to receive(:read).with(file).and_return("<button>Click me</button>")
        allow(File).to receive(:exist?).with("_folder_to_watch/#{component_name}/comment.txt").and_return(false)
        allow(File).to receive(:exist?).with("_folder_to_watch/#{component_name}/doc.txt").and_return(false)
        allow(File).to receive(:exist?).with("_folder_to_watch/#{component_name}/schema.json").and_return(false)
        allow(File).to receive(:exist?).with("_folder_to_watch/#{component_name}/style.css").and_return(false)
        allow(File).to receive(:exist?).with("_folder_to_watch/#{component_name}/index.js").and_return(false)
        allow(File).to receive(:write)
      end

      it "creates a compiled liquid file with right content" do
        described_class.new(file).process

        folder_arr = component_name.split(File::SEPARATOR) -
                     described_class::LIQUID_FILE_TYPES -
                     described_class::LIQUID_FILE_TYPES.map { |type| "#{type}s" }
        expect(File).to have_received(:write).with("#{file_type}s/#{folder_arr.join("--")}.liquid", expected_content)
      end
    end
  end
end
