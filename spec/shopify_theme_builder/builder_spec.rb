# frozen_string_literal: true

require "spec_helper"

RSpec.describe ShopifyThemeBuilder::Builder do
  describe "#build" do
    let(:files_to_process) do
      {
        "_folder_to_watch/button/section.liquid" => :updated,
        "_folder_to_watch/button/schema.json" => :updated,
        "_folder_to_watch/button/style.css" => :updated,
        "_folder_to_watch/button/index.js" => :updated
      }
    end

    before do
      allow(ShopifyThemeBuilder::LiquidProcessor).to receive(:new).and_return(double(process: "processed_file"))
    end

    context "when no files are provided" do
      it "processes all files in the default components folder" do
        described_class.new(files_to_process:).build
        expect(ShopifyThemeBuilder::LiquidProcessor).to have_received(:new).exactly(4).times
      end

      it "shows correct file count in input" do
        expect { described_class.new(files_to_process:).build }.to output(/Processing 4 files\.\.\./).to_stdout
      end

      it "shows correct file count in output" do
        expect { described_class.new(files_to_process:).build }.to output(/Built 4 files\./).to_stdout
      end
    end

    context "when specific files are provided" do
      let(:files_to_process) { { "_folder_to_watch/button/section.liquid" => :updated } }

      it "processes only the specified files" do
        described_class.new(files_to_process:).build

        expect(ShopifyThemeBuilder::LiquidProcessor).to have_received(:new)
          .with(file: "_folder_to_watch/button/section.liquid", event: :updated)
      end
    end
  end
end
