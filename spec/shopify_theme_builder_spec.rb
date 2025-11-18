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
  end
end
