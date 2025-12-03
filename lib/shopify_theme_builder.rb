# frozen_string_literal: true

require "fileutils"
require "logger"
require_relative "shopify_theme_builder/version"
require_relative "shopify_theme_builder/watcher"
require_relative "shopify_theme_builder/liquid_processor"
require_relative "shopify_theme_builder/builder"
require_relative "shopify_theme_builder/command_line"

# The main module for ShopifyThemeBuilder.
module ShopifyThemeBuilder
  class << self
    def watch(
      folders_to_watch: ["_components"],
      tailwind_input_file: "./assets/tailwind.css",
      tailwind_output_file: "./assets/tailwind-output.css",
      skip_tailwind: false
    )
      create_folders(folders_to_watch)

      initial_build(folders_to_watch)

      run_tailwind(tailwind_input_file, tailwind_output_file) unless skip_tailwind

      watch_folders(folders_to_watch) do
        run_tailwind(tailwind_input_file, tailwind_output_file) unless skip_tailwind
      end
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

        yield if block_given?
      end
    end

    def run_tailwind(tailwind_input_file, tailwind_output_file)
      puts "Running Tailwind CSS build..."

      system("tailwindcss", "-i", tailwind_input_file, "-o", tailwind_output_file)
    end
  end
end
