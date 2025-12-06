# frozen_string_literal: true

require "spec_helper"

RSpec.describe ShopifyThemeBuilder::Filewatcher do
  let(:watcher) { described_class.new(["_folder_to_watch"]) }
  let(:filewatcher_instance) { watcher.instance_variable_get(:@filewatcher) }

  describe "#initialize" do
    it "sets default values" do
      expect(filewatcher_instance).to be_a(Filewatcher)
    end
  end

  describe "#method_missing" do
    it "delegates to Filewatcher's related method" do
      allow(filewatcher_instance).to receive(:watch)

      watcher.watch

      expect(filewatcher_instance).to have_received(:watch)
    end

    it "raises NoMethodError for unknown methods" do
      allow(filewatcher_instance).to receive(:respond_to?).with(:unknown_method).and_return(false)

      expect { watcher.unknown_method }.to raise_error(NoMethodError)
    end
  end

  describe "#respond_to_missing?" do
    it "returns true for methods the underlying Filewatcher responds to" do
      allow(filewatcher_instance).to receive(:respond_to?).with(:stop).and_return(true)

      expect(watcher.respond_to?(:stop)).to be true
    end

    it "returns false for methods the underlying Filewatcher does not respond to" do
      allow(filewatcher_instance).to receive(:respond_to?).with(:unknown_method).and_return(false)

      expect(watcher.respond_to?(:unknown_method)).to be false
    end
  end
end
