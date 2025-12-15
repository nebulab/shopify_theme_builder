# frozen_string_literal: true

require "spec_helper"

RSpec.describe ShopifyThemeBuilder::CommandLine do
  describe "#watch" do
    let(:default_folders) { ["_components"] }
    let(:default_tailwind_input) { "./assets/tailwind.css" }
    let(:default_tailwind_output) { "./assets/tailwind-output.css" }
    let(:skip_tailwind) { false }
    let(:default_stimulus_output) { "./assets/controllers.js" }

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
          skip_tailwind: skip_tailwind,
          stimulus_output_file: default_stimulus_output
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
          skip_tailwind: skip_tailwind,
          stimulus_output_file: default_stimulus_output
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
          skip_tailwind: skip_tailwind,
          stimulus_output_file: default_stimulus_output
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
          skip_tailwind: skip_tailwind,
          stimulus_output_file: default_stimulus_output
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
          skip_tailwind: true,
          stimulus_output_file: default_stimulus_output
        )
      end
    end

    context "when called with custom stimulus_output_file option" do
      it "passes the custom stimulus output file to ShopifyThemeBuilder.watch" do
        custom_stimulus_output = "./dist/controllers.js"

        described_class.start(["watch", "--stimulus-output-file", custom_stimulus_output])

        expect(ShopifyThemeBuilder).to have_received(:watch).with(
          folders_to_watch: default_folders,
          tailwind_input_file: default_tailwind_input,
          tailwind_output_file: default_tailwind_output,
          skip_tailwind: skip_tailwind,
          stimulus_output_file: custom_stimulus_output
        )
      end
    end

    context "when called with all custom options" do
      it "passes all custom options to ShopifyThemeBuilder.watch" do
        custom_folders = ["src/components"]
        custom_input_file = "./src/tailwind.css"
        custom_output_file = "./dist/tailwind.css"
        custom_skip_tailwind = true
        custom_stimulus_output = "./dist/controllers.js"

        described_class.start([
                                "watch",
                                "--folders", "src/components",
                                "--tailwind-input-file", custom_input_file,
                                "--tailwind-output-file", custom_output_file,
                                "--skip-tailwind", custom_skip_tailwind,
                                "--stimulus-output-file", custom_stimulus_output
                              ])

        expect(ShopifyThemeBuilder).to have_received(:watch).with(
          folders_to_watch: custom_folders,
          tailwind_input_file: custom_input_file,
          tailwind_output_file: custom_output_file,
          skip_tailwind: custom_skip_tailwind,
          stimulus_output_file: custom_stimulus_output
        )
      end
    end
  end

  describe "#generate" do
    let(:cli) { described_class.new }

    before do
      allow(cli).to receive(:directory)
      allow(cli).to receive(:say_error)
    end

    context "when all options are provided" do
      context "with section type" do
        it "generates a section component without prompting" do
          allow(cli).to receive(:options).and_return({
                                                       type: "section",
                                                       name: "MySection",
                                                       folder: "_components"
                                                     })

          cli.generate

          expect(cli).to have_received(:directory).with(
            "generators",
            "_components/mysection",
            exclude_pattern: "doc.txt"
          )
        end
      end

      context "with block type" do
        it "generates a block component without prompting" do
          allow(cli).to receive(:options).and_return({
                                                       type: "block",
                                                       name: "MyBlock",
                                                       folder: "_components"
                                                     })

          cli.generate

          expect(cli).to have_received(:directory).with(
            "generators",
            "_components/myblock",
            exclude_pattern: "doc.txt"
          )
        end
      end

      context "with snippet type" do
        it "generates a snippet component without schema.json" do
          allow(cli).to receive(:options).and_return({
                                                       type: "snippet",
                                                       name: "MySnippet",
                                                       folder: "_components"
                                                     })

          cli.generate

          expect(cli).to have_received(:directory).with(
            "generators",
            "_components/mysnippet",
            exclude_pattern: "schema.json"
          )
        end
      end
    end

    context "when type is not provided" do
      before do
        allow(cli).to receive(:options).and_return({
                                                     type: nil,
                                                     name: "TestComponent",
                                                     folder: "_components"
                                                   })
        allow(cli).to receive(:ask).with(
          "Enter component type (section, block or snippet):",
          limited_to: ShopifyThemeBuilder::CommandLine::SUPPORTED_TYPES
        ).and_return("section")
      end

      it "asks for type" do
        cli.generate

        expect(cli).to have_received(:ask).with(
          "Enter component type (section, block or snippet):",
          limited_to: ShopifyThemeBuilder::CommandLine::SUPPORTED_TYPES
        )
      end

      it "generates component with provided type" do
        cli.generate

        expect(cli).to have_received(:directory).with(
          "generators",
          "_components/testcomponent",
          exclude_pattern: "doc.txt"
        )
      end
    end

    context "when type is invalid" do
      before do
        allow(cli).to receive(:options).and_return({
                                                     type: "invalid",
                                                     name: "TestComponent",
                                                     folder: "_components"
                                                   })
        allow(cli).to receive(:ask).with(
          "Enter component type (section, block or snippet):",
          limited_to: ShopifyThemeBuilder::CommandLine::SUPPORTED_TYPES
        ).and_return("section")
      end

      it "shows error for invalid type" do
        cli.generate

        expect(cli).to have_received(:say_error)
          .with("Error: Unsupported type 'invalid'. Supported types are: section, block, snippet")
      end

      it "asks for type again" do
        cli.generate

        expect(cli).to have_received(:ask).with(
          "Enter component type (section, block or snippet):",
          limited_to: ShopifyThemeBuilder::CommandLine::SUPPORTED_TYPES
        )
      end
    end

    context "when name is not provided" do
      before do
        allow(cli).to receive(:options).and_return({
                                                     type: "section",
                                                     name: nil,
                                                     folder: "_components"
                                                   })
        allow(cli).to receive(:ask).with("Enter component name (E.g., Slideshow):").and_return("MyComponent")
      end

      it "asks for name" do
        cli.generate

        expect(cli).to have_received(:ask).with("Enter component name (E.g., Slideshow):")
      end

      it "generates component with provided name" do
        cli.generate

        expect(cli).to have_received(:directory).with(
          "generators",
          "_components/mycomponent",
          exclude_pattern: "doc.txt"
        )
      end
    end

    context "when folder is not provided" do
      before do
        allow(cli).to receive(:options).and_return({
                                                     type: "section",
                                                     name: "TestComponent",
                                                     folder: nil
                                                   })
        allow(cli).to receive(:ask).with("Enter folder to generate the component in:",
                                         default: "_components").and_return("custom_components")
      end

      it "asks for folder with default value" do
        cli.generate

        expect(cli).to have_received(:ask).with("Enter folder to generate the component in:", default: "_components")
      end

      it "generates component in provided folder" do
        cli.generate

        expect(cli).to have_received(:directory).with(
          "generators",
          "custom_components/testcomponent",
          exclude_pattern: "doc.txt"
        )
      end
    end

    context "when multiple options are missing" do
      before do
        allow(cli).to receive(:options).and_return({
                                                     type: nil,
                                                     name: nil,
                                                     folder: nil
                                                   })
        allow(cli).to receive(:ask).with(
          "Enter component type (section, block or snippet):",
          limited_to: ShopifyThemeBuilder::CommandLine::SUPPORTED_TYPES
        ).and_return("block")
        allow(cli).to receive(:ask).with("Enter component name (E.g., Slideshow):").and_return("MyBlock")
        allow(cli).to receive(:ask).with("Enter folder to generate the component in:",
                                         default: "_components").and_return("_components")
      end

      it "asks for type" do
        cli.generate

        expect(cli).to have_received(:ask).with(
          "Enter component type (section, block or snippet):",
          limited_to: ShopifyThemeBuilder::CommandLine::SUPPORTED_TYPES
        )
      end

      it "asks for name" do
        cli.generate

        expect(cli).to have_received(:ask).with("Enter component name (E.g., Slideshow):")
      end

      it "asks for folder" do
        cli.generate

        expect(cli).to have_received(:ask).with("Enter folder to generate the component in:", default: "_components")
      end

      it "generates component with all provided options" do
        cli.generate

        expect(cli).to have_received(:directory).with(
          "generators",
          "_components/myblock",
          exclude_pattern: "doc.txt"
        )
      end
    end

    context "when name contains spaces and special characters" do
      it "parameterizes the name correctly" do
        allow(cli).to receive(:options).and_return({
                                                     type: "section",
                                                     name: "My Awesome Component!",
                                                     folder: "_components"
                                                   })

        cli.generate

        expect(cli).to have_received(:directory).with(
          "generators",
          "_components/my_awesome_component",
          exclude_pattern: "doc.txt"
        )
      end
    end
  end

  describe ".source_root" do
    it "returns the correct source root path" do
      expected_path = File.expand_path("../..", __dir__)
      expect(described_class.source_root).to eq(expected_path)
    end
  end
end
