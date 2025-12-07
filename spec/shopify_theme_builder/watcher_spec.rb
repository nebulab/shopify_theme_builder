# frozen_string_literal: true

require "spec_helper"

RSpec.describe ShopifyThemeBuilder::Watcher do
  describe "#watch" do
    let(:watcher) { described_class.new }

    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(ShopifyThemeBuilder::Builder).to receive(:new).and_return(double(build: nil))
      allow(ShopifyThemeBuilder::Filewatcher).to receive(:new).and_return(double(watch: nil))
      allow(Dir).to receive(:pwd).and_return("/path/to/project")
      allow(Dir).to receive(:glob).with("_components/**/*.*").and_return(["_components/button/block.liquid"])
      allow(Dir).to receive(:glob).with("_components/**/controller.js").and_return([])
      allow(File).to receive(:exist?).and_return(true)
      allow(watcher).to receive(:system)
    end

    it "outputs creating folders message" do
      expect { watcher.watch }.to output(/Creating necessary folders/).to_stdout
    end

    it "creates necessary folders" do
      watcher.watch

      expect(FileUtils).to have_received(:mkdir_p).exactly(4).times
    end

    it "outputs initial build message" do
      expect { watcher.watch }.to output(/Doing an initial build/).to_stdout
    end

    it "performs an initial build" do
      watcher.watch

      expect(ShopifyThemeBuilder::Builder).to have_received(:new)
        .with(files_to_process: ["_components/button/block.liquid"])
    end

    it "runs Tailwind CSS build" do
      expect { watcher.watch }.to output(/Running Tailwind CSS build/).to_stdout
    end

    it "calls system to run Tailwind CSS" do
      watcher.watch

      expect(watcher).to have_received(:system)
        .with("tailwindcss", "-i", "./assets/tailwind.css", "-o", "./assets/tailwind-output.css")
    end

    context "when custom tailwind input and output files are provided" do
      let(:watcher) do
        described_class.new(
          tailwind_input_file: "input.css",
          tailwind_output_file: "output.css"
        )
      end

      it "calls Tailwind CSS build using the specified input and output files" do
        watcher.watch

        expect(watcher).to have_received(:system).with("tailwindcss", "-i", "input.css", "-o", "output.css")
      end
    end

    it "runs Stimulus build" do
      watcher.watch

      expect(Dir).to have_received(:glob).with("_components/**/controller.js").once
    end

    it "outputs watching message" do
      expect { watcher.watch }.to output(/Watching for changes in '_components' folder/).to_stdout
    end

    it "starts watching for file changes" do
      watcher.watch

      expect(ShopifyThemeBuilder::Filewatcher).to have_received(:new).with(["_components"])
    end

    it "sets up a watch block to handle file changes" do
      spy = double(watch: nil)
      allow(ShopifyThemeBuilder::Filewatcher).to receive(:new).and_return(spy)

      watcher.watch

      expect(spy).to have_received(:watch)
    end

    context "when files change in components folder" do
      before do
        spy = double(watch: nil)
        allow(ShopifyThemeBuilder::Filewatcher).to receive(:new).and_return(spy)
        allow(spy).to receive(:watch) do |&block|
          changes = {
            "/path/to/project/_components/button/schema.json" => :created
          }
          block&.call(changes)
        end
      end

      it "processes files when changes are detected in components folder" do
        watcher.watch

        expect(ShopifyThemeBuilder::Builder).to have_received(:new)
          .with(files_to_process: ["_components/button/schema.json"])
      end

      it "runs Tailwind CSS build after processing changes" do
        watcher.watch

        expect(watcher).to have_received(:system)
          .with("tailwindcss", "-i", "./assets/tailwind.css", "-o", "./assets/tailwind-output.css").twice
      end

      context "when a controller.js file changes" do
        before do
          spy = double(watch: nil)
          allow(ShopifyThemeBuilder::Filewatcher).to receive(:new).and_return(spy)
          allow(spy).to receive(:watch) do |&block|
            changes = {
              "/path/to/project/_components/button/controller.js" => :updated
            }
            block&.call(changes)
          end
        end

        it "runs Stimulus build after processing changes" do
          watcher.watch

          expect(Dir).to have_received(:glob).with("_components/**/controller.js").twice
        end
      end
    end

    context "when skip_tailwind is true" do
      let(:watcher) { described_class.new(skip_tailwind: true) }

      it "does not run Tailwind CSS build" do
        watcher.watch

        expect(watcher).not_to have_received(:system)
          .with("tailwindcss", "-i", "./assets/tailwind.css", "-o", "./assets/tailwind-output.css")
      end
    end

    context "when controllers files are present" do
      before do
        allow(Dir).to receive(:glob).with("_components/**/controller.js").and_return(
          ["_components/button/controller.js"]
        )
        allow(File).to receive(:read).and_return("// controller content")
        allow(File).to receive(:write)
      end

      it "outputs building Stimulus controllers message" do
        expect { watcher.watch }.to output(/Building Stimulus controllers/).to_stdout
      end

      it "creates the folders for the Stimulus output file" do
        watcher.watch

        expect(FileUtils).to have_received(:mkdir_p).with(File.dirname("./assets/controllers.js"))
      end

      it "writes the combined Stimulus controllers to the output file" do
        watcher.watch

        expect(File).to have_received(:write).with(
          "./assets/controllers.js",
          "import { Application, Controller } from \"https://unpkg.com/@hotwired/stimulus/dist/stimulus.js\"\n\
window.Stimulus = Application.start()\n\n\
// controller content"
        )
      end

      context "when custom stimulus output file is provided" do
        let(:watcher) do
          described_class.new(
            stimulus_output_file: "custom/controllers.js"
          )
        end

        it "writes the combined Stimulus controllers to the specified output file" do
          watcher.watch

          expect(File).to have_received(:write).with(
            "custom/controllers.js",
            "import { Application, Controller } from \"https://unpkg.com/@hotwired/stimulus/dist/stimulus.js\"\n\
window.Stimulus = Application.start()\n\n\
// controller content"
          )
        end
      end

      context "when multiple controller files are present" do
        before do
          allow(Dir).to receive(:glob).with("_components/**/controller.js").and_return(
            [
              "_components/button/controller.js",
              "_components/modal/controller.js"
            ]
          )
          allow(File).to receive(:read).with("_components/button/controller.js").and_return(
            "// button controller content\n"
          )
          allow(File).to receive(:read).with("_components/modal/controller.js").and_return(
            "// modal controller content"
          )
        end

        it "combines all controller files into the output file" do
          watcher.watch

          expect(File).to have_received(:write).with(
            "./assets/controllers.js",
            "import { Application, Controller } from \"https://unpkg.com/@hotwired/stimulus/dist/stimulus.js\"\n\
window.Stimulus = Application.start()\n\n\
// button controller content\n\n\
// modal controller content"
          )
        end
      end

      context "when multiple folders are watched with controllers" do
        let(:watcher) do
          described_class.new(folders_to_watch: %w[_components _custom])
        end

        before do
          allow(Dir).to receive(:glob).with("_custom/**/*.*")
          allow(Dir).to receive(:glob).with("_components/**/controller.js")
                                      .and_return(["_components/button/controller.js"])
          allow(Dir).to receive(:glob).with("_custom/**/controller.js").and_return(["_custom/widget/controller.js"])
        end

        it "combines controllers from _components watched folders" do
          watcher.watch

          expect(Dir).to have_received(:glob).with("_components/**/controller.js")
        end

        it "combines controllers from _custom watched folders" do
          watcher.watch

          expect(Dir).to have_received(:glob).with("_custom/**/controller.js")
        end
      end
    end

    context "when files outside components folder change" do
      before do
        spy = double(watch: nil)
        allow(ShopifyThemeBuilder::Filewatcher).to receive(:new).and_return(spy)
        allow(spy).to receive(:watch) do |&block|
          changes = {
            "/path/to/project/_non_components_folder/button/block.liquid" => :updated
          }
          block&.call(changes)
        end
      end

      it "does not process files outside components folder" do
        watcher.watch

        expect(ShopifyThemeBuilder::Builder).not_to have_received(:new)
          .with(files_to_process: ["_non_components_folder/button/block.liquid"])
      end
    end

    context "when tailwind input file does not exist" do
      before do
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:write)
        stub_const("Tailwindcss::Ruby::VERSION", "4.1.17")
      end

      it "creates the tailwind input file" do
        expect { watcher.watch }.to output(/Creating default Tailwind CSS input file/).to_stdout
      end

      it "creates necessary directories for the tailwind input file" do
        watcher.watch

        expect(FileUtils).to have_received(:mkdir_p).with(File.dirname("./assets/tailwind.css"))
      end

      it "writes the correct base config to the tailwind input file for version >= 4.0.0" do
        watcher.watch

        expect(File).to have_received(:write).with(
          "./assets/tailwind.css",
          '@import "tailwindcss";'
        )
      end

      it "does not initialize tailwind.config.js if it does not exist" do
        watcher.watch

        expect(watcher).not_to have_received(:system).with("tailwindcss", "init")
      end

      context "when tailwindcss-ruby version is less than 4.0.0" do
        before do
          stub_const("Tailwindcss::Ruby::VERSION", "3.3.2")
        end

        it "writes the correct base config to the tailwind input file for version < 4.0.0" do
          watcher.watch

          expect(File).to have_received(:write).with(
            "./assets/tailwind.css",
            "@tailwind base;\n@tailwind components;\n@tailwind utilities;"
          )
        end

        it "initializes tailwind.config.js if it does not exist" do
          watcher.watch

          expect(watcher).to have_received(:system).with("tailwindcss", "init")
        end

        context "when tailwind.config.js already exists" do
          before do
            allow(File).to receive(:exist?).with("./assets/tailwind.css").and_return(false)
            allow(File).to receive(:exist?).with("tailwind.config.js").and_return(true)
          end

          it "does not initialize tailwind.config.js" do
            watcher.watch

            expect(watcher).not_to have_received(:system).with("tailwindcss", "init")
          end
        end
      end

      context "when skip_tailwind is true" do
        let(:watcher) { described_class.new(skip_tailwind: true) }

        it "does not create the tailwind input file" do
          watcher.watch

          expect(File).not_to have_received(:write)
        end
      end
    end
  end
end
