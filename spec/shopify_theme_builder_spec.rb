# frozen_string_literal: true

RSpec.describe ShopifyThemeBuilder do
  it "has a version number" do
    expect(ShopifyThemeBuilder::VERSION).not_to be_nil
  end

  describe ".watch" do
    it "delegates to Watcher" do
      spy = double(watch: nil)
      allow(ShopifyThemeBuilder::Watcher).to receive(:new).and_return(spy)

      described_class.watch

      expect(spy).to have_received(:watch)
    end
  end
end
