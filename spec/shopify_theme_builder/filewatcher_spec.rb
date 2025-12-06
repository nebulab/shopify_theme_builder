# frozen_string_literal: true

require "spec_helper"

RSpec.describe ShopifyThemeBuilder::Filewatcher do
  describe "#initialize" do
    it "sets default values" do
      watcher = described_class.new(["_folder_to_watch"])
      expect(watcher.instance_variable_get(:@filewatcher)).to be_a(Filewatcher)
    end
  end

  describe "#watch" do
    it "delegates to Filewatcher's watch method" do
      watcher = described_class.new(["_folder_to_watch"])
      filewatcher = watcher.instance_variable_get(:@filewatcher)
      allow(filewatcher).to receive(:watch)
      watcher.watch
      expect(filewatcher).to have_received(:watch)
    end
  end
end
