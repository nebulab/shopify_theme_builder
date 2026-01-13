# frozen_string_literal: true

require "active_support/core_ext/string/inflections"
require "thor"

module ShopifyThemeBuilder
  # CommandLine class to handle CLI commands using Thor.
  class CommandLine < Thor
    include Thor::Actions

    SUPPORTED_TYPES = %w[section block snippet].freeze

    attr_reader :type, :name

    def self.source_root
      File.expand_path("../..", __dir__)
    end

    desc "watch", "Watch for changes in the components folder and build the theme accordingly"
    method_option :folders, type: :array, default: ["_components"], desc: "Folders to watch for changes"
    method_option :tailwind_input_file, type: :string, default: "./assets/tailwind.css", desc: "Tailwind CSS input file"
    method_option :tailwind_output_file, type: :string, default: "./assets/tailwind-output.css",
                                         desc: "Tailwind CSS output file"
    method_option :skip_tailwind, type: :boolean, default: false, desc: "Skip Tailwind CSS processing"
    method_option :stimulus_output_file, type: :string, default: "./assets/controllers.js",
                                         desc: "Stimulus controllers output file"
    def watch
      ShopifyThemeBuilder.watch(
        folders_to_watch: options[:folders],
        tailwind_input_file: options[:tailwind_input_file],
        tailwind_output_file: options[:tailwind_output_file],
        skip_tailwind: options[:skip_tailwind],
        stimulus_output_file: options[:stimulus_output_file]
      )
    end

    desc "install", "Set up your Shopify theme with Tailwind CSS, Stimulus JS, and the file watcher"
    def install
    end

    desc "generate", "Generate an example component structure"
    method_option :type, type: :string, desc: "Type of component to generate ('section', 'block' or 'snippet')"
    method_option :name, type: :string, desc: "Name of the component to generate"
    method_option :folder, type: :string, desc: "Folder to generate the component in"
    def generate
      @type = options[:type]
      @name = options[:name]
      folder = options[:folder]

      until ShopifyThemeBuilder::CommandLine::SUPPORTED_TYPES.include?(@type)
        unless @type.nil?
          say_error "Error: Unsupported type '#{@type}'.\
 Supported types are: #{ShopifyThemeBuilder::CommandLine::SUPPORTED_TYPES.join(", ")}"
        end

        @type = ask(
          "Enter component type (section, block or snippet):",
          limited_to: ShopifyThemeBuilder::CommandLine::SUPPORTED_TYPES
        )
      end

      @name = ask("Enter component name (E.g., Slideshow):") if @name.nil?

      folder = ask("Enter folder to generate the component in:", default: "_components") if folder.nil?

      directory "generators", "#{folder}/#{@name.parameterize(separator: "_")}", exclude_pattern:
    end

    private

    def exclude_pattern
      return "doc.txt" unless @type == "snippet"

      "schema.json"
    end
  end
end
