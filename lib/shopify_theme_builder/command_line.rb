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
      add_tailwind_to_theme
      add_stimulus_to_theme
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

    def add_tailwind_to_theme
      theme_file_path =
        if File.exist?("snippets/stylesheets.liquid")
          "snippets/stylesheets.liquid"
        elsif File.exist?("layout/theme.liquid")
          "layout/theme.liquid"
        end

      unless theme_file_path
        say_error "Error: Could not find a theme file to inject Tailwind CSS.", :red
        return
      end

      theme_file = File.read(theme_file_path)

      if theme_file.include?("tailwind-output.css")
        say "Tailwind CSS already included in #{theme_file_path}. Skipping injection.", :blue
        return
      end

      injection_tag = "{{ 'tailwind-output.css' | asset_url | stylesheet_tag }}"

      if theme_file_path == "snippets/stylesheets.liquid"
        add_tailwind_to_snippet(theme_file_path, theme_file, injection_tag)
      else
        add_tailwind_to_layout(theme_file_path, theme_file, injection_tag)
      end
    end

    def add_tailwind_to_snippet(theme_file_path, theme_file, injection_tag)
      File.write(theme_file_path, "#{theme_file.chomp}\n#{injection_tag}\n")
      say "Injected Tailwind CSS tag into #{theme_file_path}.", :green
    end

    def add_tailwind_to_layout(theme_file_path, theme_file, injection_tag)
      stylesheet_tag_regex =
        /(\{\{\s*['"][^'"]+['"]\s*\|\s*asset_url\s*\|\s*stylesheet_tag(?:\s*:\s*((?!\}\}).)*)?\s*\}\})/
      if theme_file.match?(stylesheet_tag_regex)
        updated_content = theme_file.sub(
          stylesheet_tag_regex,
          "\\1\n#{injection_tag}"
        )
        File.write(theme_file_path, updated_content)
        say "Injected Tailwind CSS tag into #{theme_file_path}.", :green
      else
        say_error "Error: Could not find a way to inject Tailwind CSS. Please manually add the CSS tag.",
                  :red
      end
    end

    def add_stimulus_to_theme
      theme_file_path =
        if File.exist?("snippets/scripts.liquid")
          "snippets/scripts.liquid"
        elsif File.exist?("layout/theme.liquid")
          "layout/theme.liquid"
        end

      unless theme_file_path
        say_error "Error: Could not find a theme file to inject Stimulus JS.", :red
        return
      end

      theme_file = File.read(theme_file_path)

      if theme_file.include?("controllers.js")
        say "Stimulus JS already included in #{theme_file_path}. Skipping injection.", :blue
        return
      end

      injection_tag = "<script type=\"module\" defer=\"defer\" src=\"{{ 'controllers.js' | asset_url }}\"></script>"

      if theme_file_path == "snippets/scripts.liquid"
        add_stimulus_to_snippet(theme_file_path, theme_file, injection_tag)
      else
        add_stimulus_to_layout(theme_file_path, theme_file, injection_tag)
      end
    end

    def add_stimulus_to_snippet(theme_file_path, theme_file, injection_tag)
      File.write(theme_file_path, "#{theme_file.chomp}\n#{injection_tag}\n")
      say "Injected Stimulus JS tag into #{theme_file_path}.", :green
    end

    def add_stimulus_to_layout(theme_file_path, theme_file, injection_tag)
      script_tag_regex = %r{(\s*)</body>}
      if theme_file.match?(script_tag_regex)
        updated_content = theme_file.sub(
          script_tag_regex,
          "\\1\n#{injection_tag}\n</body>"
        )
        File.write(theme_file_path, updated_content)
        say "Injected Stimulus JS tag into #{theme_file_path}.", :green
      else
        say_error "Error: Could not find a way to inject Stimulus JS. Please manually add the JS tag.",
                  :red
      end
    end
  end
end
