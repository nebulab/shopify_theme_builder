# frozen_string_literal: true

RSpec.describe ShopifyThemeBuilder do
  it "has a version number" do
    expect(ShopifyThemeBuilder::VERSION).not_to be_nil
  end

  describe ".watch" do
    before do
      allow(FileUtils).to receive(:mkdir_p)
      allow(ShopifyThemeBuilder::Builder).to receive(:new).and_return(double(build: nil))
      allow(ShopifyThemeBuilder::Watcher).to receive(:new).and_return(double(watch: nil))
      allow(Dir).to receive_messages(pwd: "/path/to/project", glob: ["_components/button/block.liquid"])
      allow(described_class).to receive(:system)
      allow(File).to receive(:exist?).and_return(true)
    end

    it "outputs creating folders message" do
      expect { described_class.watch }.to output(/Creating necessary folders/).to_stdout
    end

    it "creates necessary folders" do
      described_class.watch

      expect(FileUtils).to have_received(:mkdir_p).exactly(4).times
    end

    it "outputs initial build message" do
      expect { described_class.watch }.to output(/Doing an initial build/).to_stdout
    end

    it "performs an initial build" do
      described_class.watch

      expect(ShopifyThemeBuilder::Builder).to have_received(:new)
        .with(files_to_process: ["_components/button/block.liquid"])
    end

    it "runs Tailwind CSS build" do
      expect { described_class.watch }.to output(/Running Tailwind CSS build/).to_stdout
    end

    it "calls system to run Tailwind CSS" do
      described_class.watch

      expect(described_class).to have_received(:system)
        .with("tailwindcss", "-i", "./assets/tailwind.css", "-o", "./assets/tailwind-output.css")
    end

    it "calls Tailwind CSS build using the specified input and output files" do
      described_class.watch(
        tailwind_input_file: "input.css",
        tailwind_output_file: "output.css"
      )

      expect(described_class).to have_received(:system).with("tailwindcss", "-i", "input.css", "-o", "output.css")
    end

    it "outputs watching message" do
      expect { described_class.watch }.to output(/Watching for changes in '_components' folder/).to_stdout
    end

    it "starts watching for file changes" do
      described_class.watch

      expect(ShopifyThemeBuilder::Watcher).to have_received(:new).with(["_components"])
    end

    it "sets up a watch block to handle file changes" do
      spy = double(watch: nil)
      allow(ShopifyThemeBuilder::Watcher).to receive(:new).and_return(spy)

      described_class.watch

      expect(spy).to have_received(:watch)
    end

    context "when files change in components folder" do
      before do
        spy = double(watch: nil)
        allow(ShopifyThemeBuilder::Watcher).to receive(:new).and_return(spy)
        allow(spy).to receive(:watch) do |&block|
          changes = {
            "/path/to/project/_components/button/schema.json" => :created
          }
          block&.call(changes)
        end
      end

      it "processes files when changes are detected in components folder" do
        described_class.watch

        expect(ShopifyThemeBuilder::Builder).to have_received(:new)
          .with(files_to_process: ["_components/button/schema.json"])
      end

      it "runs Tailwind CSS build after processing changes" do
        described_class.watch

        expect(described_class).to have_received(:system)
          .with("tailwindcss", "-i", "./assets/tailwind.css", "-o", "./assets/tailwind-output.css").twice
      end
    end

    context "when skip_tailwind is true" do
      it "does not run Tailwind CSS build" do
        described_class.watch(skip_tailwind: true)

        expect(described_class).not_to have_received(:system)
          .with("tailwindcss", "-i", "./assets/tailwind.css", "-o", "./assets/tailwind-output.css")
      end
    end

    context "when files outside components folder change" do
      before do
        spy = double(watch: nil)
        allow(ShopifyThemeBuilder::Watcher).to receive(:new).and_return(spy)
        allow(spy).to receive(:watch) do |&block|
          changes = {
            "/path/to/project/_non_components_folder/button/block.liquid" => :updated
          }
          block&.call(changes)
        end
      end

      it "does not process files outside components folder" do
        described_class.watch

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
        expect { described_class.watch }.to output(/Creating default Tailwind CSS input file/).to_stdout
      end

      it "creates necessary directories for the tailwind input file" do
        described_class.watch

        expect(FileUtils).to have_received(:mkdir_p).with(File.dirname("./assets/tailwind.css"))
      end

      it "writes the correct base config to the tailwind input file for version >= 4.0.0" do
        described_class.watch

        expect(File).to have_received(:write).with(
          "./assets/tailwind.css",
          '@import "tailwindcss";'
        )
      end

      it "does not initialize tailwind.config.js if it does not exist" do
        described_class.watch

        expect(described_class).not_to have_received(:system).with("tailwindcss", "init")
      end

      context "when tailwindcss-ruby version is less than 4.0.0" do
        before do
          stub_const("Tailwindcss::Ruby::VERSION", "3.3.2")
        end

        it "writes the correct base config to the tailwind input file for version < 4.0.0" do
          described_class.watch

          expect(File).to have_received(:write).with(
            "./assets/tailwind.css",
            "@tailwind base;\n@tailwind components;\n@tailwind utilities;"
          )
        end

        it "initializes tailwind.config.js if it does not exist" do
          described_class.watch

          expect(described_class).to have_received(:system).with("tailwindcss", "init")
        end

        context "when tailwind.config.js already exists" do
          before do
            allow(File).to receive(:exist?).with("./assets/tailwind.css").and_return(false)
            allow(File).to receive(:exist?).with("tailwind.config.js").and_return(true)
          end

          it "does not initialize tailwind.config.js" do
            described_class.watch

            expect(described_class).not_to have_received(:system).with("tailwindcss", "init")
          end
        end
      end
    end
  end
end
