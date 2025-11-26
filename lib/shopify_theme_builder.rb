# frozen_string_literal: true

require "fileutils"
require "logger"
require_relative "shopify_theme_builder/version"
require_relative "shopify_theme_builder/watcher"
require_relative "shopify_theme_builder/liquid_processor"
require_relative "shopify_theme_builder/builder"

# The main module for ShopifyThemeBuilder.
module ShopifyThemeBuilder
  class << self
    def watch(folders_to_watch: ["_components"])
      create_folders(folders_to_watch)

      initial_build(folders_to_watch)

      watch_folders(folders_to_watch)
    end

    private

    def create_folders(folders_to_watch)
      puts "Creating necessary folders..."

      FileUtils.mkdir_p(folders_to_watch)
      FileUtils.mkdir_p("sections")
      FileUtils.mkdir_p("blocks")
      FileUtils.mkdir_p("snippets")
    end

    def initial_build(folders_to_watch)
      puts "Doing an initial build..."

      folders_to_watch.each do |folder|
        Builder.new(files_to_process: Dir.glob("#{folder}/**/*.*")).build
      end
    end

    def watch_folders(folders_to_watch)
      puts "Watching for changes in '#{folders_to_watch.join(", ")}' folders..."

      Watcher.new(folders_to_watch).watch do |changes|
        changes.each_key do |filename|
          relative_filename = filename.gsub("#{Dir.pwd}/", "")

          Builder.new(files_to_process: [relative_filename]).build if relative_filename.start_with?(*folders_to_watch)
        end
      end
    end
  end
end
