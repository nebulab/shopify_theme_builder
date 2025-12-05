# frozen_string_literal: true

require "spec_helper"

# rubocop:disable RSpec/ExampleLength
RSpec.describe ShopifyThemeBuilder::CommandLine do
  describe "#watch" do
    let(:default_folders) { ["_components"] }
    let(:default_tailwind_input) { "./assets/tailwind.css" }
    let(:default_tailwind_output) { "./assets/tailwind-output.css" }
    let(:skip_tailwind) { false }

    before do
      allow(ShopifyThemeBuilder).to receive(:watch)
    end

    context "when called with default options" do
      it "calls ShopifyThemeBuilder.watch with default parameters" do
        described_class.start(["watch"])

        expect(ShopifyThemeBuilder).to have_received(:watch).with(
          folders_to_watch: default_folders,
          tailwind_input_file: default_tailwind_input,
          tailwind_output_file: default_tailwind_output,
          skip_tailwind: skip_tailwind
        )
      end
    end

    context "when called with custom folders option" do
      it "passes the custom folders to ShopifyThemeBuilder.watch" do
        custom_folders = %w[components custom]

        described_class.start(["watch", "--folders", "components", "custom"])

        expect(ShopifyThemeBuilder).to have_received(:watch).with(
          folders_to_watch: custom_folders,
          tailwind_input_file: default_tailwind_input,
          tailwind_output_file: default_tailwind_output,
          skip_tailwind: skip_tailwind
        )
      end
    end

    context "when called with custom tailwind_input_file option" do
      it "passes the custom input file to ShopifyThemeBuilder.watch" do
        custom_input_file = "./src/styles/main.css"

        described_class.start(["watch", "--tailwind-input-file", custom_input_file])

        expect(ShopifyThemeBuilder).to have_received(:watch).with(
          folders_to_watch: default_folders,
          tailwind_input_file: custom_input_file,
          tailwind_output_file: default_tailwind_output,
          skip_tailwind: skip_tailwind
        )
      end
    end

    context "when called with custom tailwind_output_file option" do
      it "passes the custom output file to ShopifyThemeBuilder.watch" do
        custom_output_file = "./dist/styles.css"

        described_class.start(["watch", "--tailwind-output-file", custom_output_file])

        expect(ShopifyThemeBuilder).to have_received(:watch).with(
          folders_to_watch: default_folders,
          tailwind_input_file: default_tailwind_input,
          tailwind_output_file: custom_output_file,
          skip_tailwind: skip_tailwind
        )
      end
    end

    context "when called with skip_tailwind option" do
      it "passes the skip_tailwind flag to ShopifyThemeBuilder.watch" do
        described_class.start(["watch", "--skip-tailwind", true])

        expect(ShopifyThemeBuilder).to have_received(:watch).with(
          folders_to_watch: default_folders,
          tailwind_input_file: default_tailwind_input,
          tailwind_output_file: default_tailwind_output,
          skip_tailwind: true
        )
      end
    end

    context "when called with all custom options" do
      it "passes all custom options to ShopifyThemeBuilder.watch" do
        custom_folders = ["src/components"]
        custom_input_file = "./src/tailwind.css"
        custom_output_file = "./dist/tailwind.css"
        custom_skip_tailwind = true

        described_class.start([
                                "watch",
                                "--folders", "src/components",
                                "--tailwind-input-file", custom_input_file,
                                "--tailwind-output-file", custom_output_file,
                                "--skip-tailwind", custom_skip_tailwind
                              ])

        expect(ShopifyThemeBuilder).to have_received(:watch).with(
          folders_to_watch: custom_folders,
          tailwind_input_file: custom_input_file,
          tailwind_output_file: custom_output_file,
          skip_tailwind: custom_skip_tailwind
        )
      end
    end
  end
end
# rubocop:enable RSpec/ExampleLength
