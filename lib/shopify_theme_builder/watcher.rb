# frozen_string_literal: true

require "filewatcher"

module ShopifyThemeBuilder
  # Watcher class for ShopifyThemeBuilder.
  # It wraps the Filewatcher functionality to monitor file changes.
  # It delegates method calls to the underlying Filewatcher instance.
  # Check: https://github.com/filewatcher/filewatcher
  class Watcher
    def initialize(...)
      @filewatcher = Filewatcher.new(...)
    end

    def method_missing(name, ...)
      if @filewatcher.respond_to?(name)
        @filewatcher.send(name, ...)
      else
        super
      end
    end

    def respond_to_missing?(name, include_private)
      @filewatcher.respond_to?(name) || super
    end
  end
end
