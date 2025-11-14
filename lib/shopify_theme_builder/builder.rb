# frozen_string_literal: true

module ShopifyThemeBuilder
  # Builder is responsible for building Shopify theme files
  # by delegating processing to appropriate classes based on file types.
  class Builder
    def initialize(files_to_process:)
      @files_to_process = files_to_process
      @processed_files = []
    end

    def build
      puts "Processing #{@files_to_process.count} files..."

      @files_to_process.each do |file|
        @processed_files << ShopifyThemeBuilder::LiquidProcessor.new(file).process
      end

      puts "Built #{@processed_files.count} files." if @processed_files.any?
    end
  end
end
