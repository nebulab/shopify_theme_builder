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

  describe "#install" do
    let(:cli) { described_class.new }

    before do
      allow(File).to receive(:write)
      allow(cli).to receive(:say)
      allow(cli).to receive(:say_error)
    end

    context "when layout/theme.liquid exists" do
      let(:theme_file_path) { "layout/theme.liquid" }
      let(:theme_content) do
        <<~LIQUID
          {{ 'application.css' | asset_url | stylesheet_tag }}
        LIQUID
      end

      before do
        allow(File).to receive(:exist?).with("snippets/stylesheets.liquid").and_return(false)
        allow(File).to receive(:exist?).with("snippets/scripts.liquid").and_return(false)
        allow(File).to receive(:exist?).with("layout/theme.liquid").and_return(true)
        allow(File).to receive(:read).with(theme_file_path).and_return(theme_content.dup)
      end

      it "injects Tailwind CSS after existing stylesheet tag" do
        cli.install

        expect(File).to have_received(:write).with(
          theme_file_path,
          a_string_including("{{ 'tailwind-output.css' | asset_url | stylesheet_tag }}")
        )
      end

      it "shows success message" do
        cli.install

        expect(cli).to have_received(:say).with(
          "Injected Tailwind CSS tag into #{theme_file_path}.",
          :green
        )
      end

      it "places Tailwind CSS tag on new line after existing tag" do
        cli.install

        expect(File).to have_received(:write).with(
          theme_file_path,
          a_string_matching(/application\.css.*?\n\{\{ 'tailwind-output\.css'/m)
        )
      end

      context "with stylesheet tag containing attributes" do
        let(:theme_content) do
          <<~LIQUID
            {{ 'base.css' | asset_url | stylesheet_tag: media: 'all' }}
          LIQUID
        end

        it "injects after stylesheet tag with attributes" do
          cli.install

          expect(File).to have_received(:write).with(
            theme_file_path,
            a_string_matching(/base\.css.*?media.*?\n\{\{ 'tailwind-output\.css'/m)
          )
        end
      end
    end

    context "when snippets/stylesheets.liquid exists" do
      let(:snippets_file_path) { "snippets/stylesheets.liquid" }
      let(:snippets_content) do
        <<~LIQUID
          {{ 'base.css' | asset_url | stylesheet_tag }}
          {{ 'components.css' | asset_url | stylesheet_tag }}
        LIQUID
      end

      before do
        allow(File).to receive(:exist?).with("snippets/stylesheets.liquid").and_return(true)
        allow(File).to receive(:exist?).with("snippets/scripts.liquid").and_return(false)
        allow(File).to receive(:exist?).with("layout/theme.liquid").and_return(true)
        allow(File).to receive(:read).with(snippets_file_path).and_return(snippets_content.dup)
        allow(File).to receive(:read).with("layout/theme.liquid").and_return("<body></body>")
      end

      it "prefers snippets file over layout file" do
        cli.install

        expect(File).to have_received(:write).with(snippets_file_path, anything)
      end

      it "appends Tailwind CSS tag at the end of the file" do
        cli.install

        expect(File).to have_received(:write).with(
          snippets_file_path,
          a_string_ending_with("{{ 'tailwind-output.css' | asset_url | stylesheet_tag }}\n")
        )
      end

      it "shows success message for snippet injection" do
        cli.install

        expect(cli).to have_received(:say).with(
          "Injected Tailwind CSS tag into #{snippets_file_path}.",
          :green
        )
      end

      context "when snippet file has trailing newline" do
        let(:snippets_content) do
          <<~LIQUID
            {{ 'base.css' | asset_url | stylesheet_tag }}

          LIQUID
        end

        it "adds Tailwind CSS tag preserving structure" do
          cli.install

          expect(File).to have_received(:write).with(
            snippets_file_path,
            a_string_including("{{ 'tailwind-output.css' | asset_url | stylesheet_tag }}")
          )
        end
      end

      context "when snippet file has no trailing newline" do
        let(:snippets_content) { "{{ 'base.css' | asset_url | stylesheet_tag }}" }

        it "adds newline before Tailwind CSS tag" do
          cli.install

          expect(File).to have_received(:write).with(
            snippets_file_path,
            "{{ 'base.css' | asset_url | stylesheet_tag }}\n{{ 'tailwind-output.css' | asset_url | stylesheet_tag }}\n"
          )
        end
      end
    end

    context "when Tailwind CSS is already included" do
      let(:theme_content) do
        <<~LIQUID
          {{ 'application.css' | asset_url | stylesheet_tag }}
          {{ 'tailwind-output.css' | asset_url | stylesheet_tag }}
        LIQUID
      end

      before do
        allow(File).to receive(:exist?).with("snippets/stylesheets.liquid").and_return(false)
        allow(File).to receive(:exist?).with("snippets/scripts.liquid").and_return(false)
        allow(File).to receive(:exist?).with("layout/theme.liquid").and_return(true)
        allow(File).to receive(:read).with("layout/theme.liquid").and_return(theme_content)
      end

      it "skips injection" do
        cli.install

        expect(File).not_to have_received(:write)
      end

      it "shows skip message" do
        cli.install

        expect(cli).to have_received(:say).with(
          "Tailwind CSS already included in layout/theme.liquid. Skipping injection.",
          :blue
        )
      end
    end

    context "when neither snippets nor layout file exists" do
      before do
        allow(File).to receive(:exist?).with("snippets/stylesheets.liquid").and_return(false)
        allow(File).to receive(:exist?).with("snippets/scripts.liquid").and_return(false)
        allow(File).to receive(:exist?).with("layout/theme.liquid").and_return(false)
      end

      it "shows error message" do
        cli.install

        expect(cli).to have_received(:say_error).with(
          "Error: Could not find a theme file to inject Tailwind CSS.",
          :red
        )
      end

      it "does not write any files" do
        cli.install

        expect(File).not_to have_received(:write)
      end

      it "returns early without processing" do
        result = cli.install

        expect(result).to be_nil
      end
    end

    context "when no stylesheet tags are found in layout file" do
      let(:theme_content) do
        <<~LIQUID
          <h1>Welcome</h1>
          <p>No stylesheets here</p>
        LIQUID
      end

      before do
        allow(File).to receive(:exist?).with("snippets/stylesheets.liquid").and_return(false)
        allow(File).to receive(:exist?).with("snippets/scripts.liquid").and_return(false)
        allow(File).to receive(:exist?).with("layout/theme.liquid").and_return(true)
        allow(File).to receive(:read).with("layout/theme.liquid").and_return(theme_content)
      end

      it "shows error message" do
        cli.install

        expect(cli).to have_received(:say_error).with(
          "Error: Could not find a way to inject Tailwind CSS. Please manually add the CSS tag.",
          :red
        )
      end

      it "does not write to the file" do
        cli.install

        expect(File).not_to have_received(:write)
      end
    end

    context "with Stimulus JS injection" do
      let(:theme_file_path) { "layout/theme.liquid" }
      let(:theme_content) do
        <<~LIQUID
          {{ 'application.css' | asset_url | stylesheet_tag }}
          </head>
          <body>
            {{ content_for_layout }}
          </body>
        LIQUID
      end

      before do
        allow(File).to receive(:exist?).with("snippets/stylesheets.liquid").and_return(false)
        allow(File).to receive(:exist?).with("snippets/scripts.liquid").and_return(false)
        allow(File).to receive(:exist?).with("layout/theme.liquid").and_return(true)
        allow(File).to receive(:read).with(theme_file_path).and_return(theme_content.dup)
      end

      it "injects both Tailwind CSS and Stimulus JS" do
        cli.install

        expect(File).to have_received(:write).twice
      end

      it "injects Stimulus JS before closing body tag" do
        cli.install

        expect(File).to have_received(:write).with(
          theme_file_path,
          a_string_including('<script type="module" defer="defer" src="{{ \'controllers.js\' | asset_url }}"></script>')
        )
      end

      it "shows success message for Stimulus injection" do
        cli.install

        expect(cli).to have_received(:say).with(
          "Injected Stimulus JS tag into #{theme_file_path}.",
          :green
        )
      end

      context "when snippets/scripts.liquid exists" do
        let(:snippets_file_path) { "snippets/scripts.liquid" }
        let(:snippets_content) do
          <<~LIQUID
            <script src="{{ 'main.js' | asset_url }}"></script>
          LIQUID
        end

        before do
          allow(File).to receive(:exist?).with("snippets/scripts.liquid").and_return(true)
          allow(File).to receive(:read).with(snippets_file_path).and_return(snippets_content.dup)
        end

        it "prefers snippets/scripts.liquid over layout" do
          cli.install

          script_tag = '<script type="module" defer="defer" ' \
                       'src="{{ \'controllers.js\' | asset_url }}"></script>'
          expect(File).to have_received(:write).with(
            snippets_file_path,
            a_string_including(script_tag)
          )
        end

        it "appends Stimulus JS tag at the end of snippet file" do
          cli.install

          script_tag = "<script type=\"module\" defer=\"defer\" " \
                       "src=\"{{ 'controllers.js' | asset_url }}\"></script>\n"
          expect(File).to have_received(:write).with(
            snippets_file_path,
            a_string_ending_with(script_tag)
          )
        end

        it "shows success message for snippet injection" do
          cli.install

          expect(cli).to have_received(:say).with(
            "Injected Stimulus JS tag into #{snippets_file_path}.",
            :green
          )
        end
      end

      context "when Stimulus JS is already included" do
        let(:theme_content) do
          <<~LIQUID
            {{ 'application.css' | asset_url | stylesheet_tag }}
            </head>
            <body>
              {{ content_for_layout }}
              <script type="module" defer="defer" src="{{ 'controllers.js' | asset_url }}"></script>
            </body>
          LIQUID
        end

        it "skips Stimulus JS injection" do
          cli.install

          expect(cli).to have_received(:say).with(
            "Stimulus JS already included in #{theme_file_path}. Skipping injection.",
            :blue
          )
        end

        it "still injects Tailwind CSS" do
          cli.install

          expect(File).to have_received(:write).with(
            theme_file_path,
            a_string_including("{{ 'tailwind-output.css' | asset_url | stylesheet_tag }}")
          )
        end
      end

      context "when both Tailwind CSS and Stimulus JS are already included" do
        let(:theme_content) do
          <<~LIQUID
            {{ 'application.css' | asset_url | stylesheet_tag }}
            {{ 'tailwind-output.css' | asset_url | stylesheet_tag }}
            </head>
            <body>
              {{ content_for_layout }}
              <script type="module" defer="defer" src="{{ 'controllers.js' | asset_url }}"></script>
            </body>
          LIQUID
        end

        it "skips Tailwind CSS injection" do
          cli.install

          expect(cli).to have_received(:say).with(
            "Tailwind CSS already included in #{theme_file_path}. Skipping injection.",
            :blue
          )
        end

        it "skips Stimulus JS injection" do
          cli.install

          expect(cli).to have_received(:say).with(
            "Stimulus JS already included in #{theme_file_path}. Skipping injection.",
            :blue
          )
        end

        it "does not write to the file" do
          cli.install

          expect(File).not_to have_received(:write)
        end
      end

      context "when no closing body tag is found" do
        let(:theme_content) do
          <<~LIQUID
            {{ 'application.css' | asset_url | stylesheet_tag }}
            </head>
            <div>
              {{ content_for_layout }}
            </div>
          LIQUID
        end

        it "shows error message" do
          cli.install

          expect(cli).to have_received(:say_error).with(
            "Error: Could not find a way to inject Stimulus JS. Please manually add the JS tag.",
            :red
          )
        end
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
