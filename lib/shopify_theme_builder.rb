# frozen_string_literal: true

require_relative "shopify_theme_builder/version"
require_relative "shopify_theme_builder/filewatcher"
require_relative "shopify_theme_builder/liquid_processor"
require_relative "shopify_theme_builder/builder"
require_relative "shopify_theme_builder/command_line"
require_relative "shopify_theme_builder/watcher"

# The main module for ShopifyThemeBuilder.
module ShopifyThemeBuilder
  def self.watch(...)
    Watcher.new(...).watch
  end
end
