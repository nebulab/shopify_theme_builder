# frozen_string_literal: true

require "thor"

module ShopifyThemeBuilder
  # CommandLine class to handle CLI commands using Thor.
  class CommandLine < Thor
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
  end
end
