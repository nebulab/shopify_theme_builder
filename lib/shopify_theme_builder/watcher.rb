# frozen_string_literal: true

require "fileutils"
require "tailwindcss/ruby"

module ShopifyThemeBuilder
  # Watcher is responsible for monitoring specified folders for changes
  # and triggering the build process for Shopify theme components.
  class Watcher
    def initialize(
      folders_to_watch: ["_components"],
      tailwind_input_file: "./assets/tailwind.css",
      tailwind_output_file: "./assets/tailwind-output.css",
      skip_tailwind: false,
      stimulus_output_file: "./assets/controllers.js"
    )
      @folders_to_watch = folders_to_watch
      @tailwind_input_file = tailwind_input_file
      @tailwind_output_file = tailwind_output_file
      @skip_tailwind = skip_tailwind
      @stimulus_output_file = stimulus_output_file
      @stimulus_controller_file = ShopifyThemeBuilder::LiquidProcessor::SUPPORTED_FILES[:stimulus]
    end

    def watch
      create_folders

      initial_build

      create_tailwind_file

      run_tailwind

      run_stimulus

      watch_folders
    end

    private

    def create_folders
      puts "Creating necessary folders..."

      FileUtils.mkdir_p(@folders_to_watch)
      FileUtils.mkdir_p("sections")
      FileUtils.mkdir_p("blocks")
      FileUtils.mkdir_p("snippets")
    end

    def initial_build
      puts "Doing an initial build..."

      @folders_to_watch.each do |folder|
        Builder.new(files_to_process: Dir.glob("#{folder}/**/*.*")).build
      end
    end

    def watch_folders
      puts "Watching for changes in '#{@folders_to_watch.join(", ")}' folders..."

      Filewatcher.new(@folders_to_watch).watch do |changes|
        changes.each_key do |filename|
          relative_filename = filename.gsub("#{Dir.pwd}/", "")

          Builder.new(files_to_process: [relative_filename]).build if relative_filename.start_with?(*@folders_to_watch)
        end

        run_tailwind

        run_stimulus if changes.keys.any? { |f| f.end_with?(@stimulus_controller_file) }
      end
    end

    def run_tailwind
      return if @skip_tailwind

      puts "Running Tailwind CSS build..."

      system("tailwindcss", "-i", @tailwind_input_file, "-o", @tailwind_output_file)
    end

    def create_tailwind_file
      return if @skip_tailwind || File.exist?(@tailwind_input_file)

      puts "Creating default Tailwind CSS input file at '#{@tailwind_input_file}'..."

      FileUtils.mkdir_p(File.dirname(@tailwind_input_file))
      File.write @tailwind_input_file, tailwind_base_config
    end

    def tailwind_base_config
      return '@import "tailwindcss";' if Gem::Version.new(Tailwindcss::Ruby::VERSION) >= Gem::Version.new("4.0.0")

      system("tailwindcss", "init") unless File.exist?("tailwind.config.js")

      <<~TAILWIND.strip
        @tailwind base;
        @tailwind components;
        @tailwind utilities;
      TAILWIND
    end

    def run_stimulus
      controllers_files = @folders_to_watch.map { Dir.glob("#{_1}/**/#{@stimulus_controller_file}") }.flatten

      return if controllers_files.empty?

      puts "Building Stimulus controllers..."

      content = +base_stimulus_content

      controllers_files.each do |file|
        content << File.read(file)
        content << "\n"
      end

      FileUtils.mkdir_p(File.dirname(@stimulus_output_file))
      File.write(@stimulus_output_file, content.strip)
    end

    def base_stimulus_content
      "import { Application, Controller } from \"https://unpkg.com/@hotwired/stimulus/dist/stimulus.js\"\n\
window.Stimulus = Application.start()\n\n"
    end
  end
end
