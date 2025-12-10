# frozen_string_literal: true

require "logger"

module ShopifyThemeBuilder
  # LiquidProcessor is responsible for processing Liquid files
  # by combining various related files (Liquid, schema, CSS, JS, doc, comment)
  # into a single compiled Liquid file suitable for Shopify themes.
  # It supports specific Liquid file types and organizes the output
  # into designated folders based on the file type.
  # Requirements:
  # - The current folder must contain one Liquid file named: section.liquid, snippet.liquid, or block.liquid.
  # - Blocks must have a schema.json file.
  # - Schema file must be named schema.json.
  # - CSS file must be named style.css.
  # - JS file must be named index.js.
  # - Documentation file must be named doc.txt.
  # - Comment file must be named comment.txt.
  class LiquidProcessor
    LIQUID_FILE_TYPES = %w[section snippet block].freeze
    SUPPORTED_FILES = {
      comment: "comment.txt",
      doc: "doc.txt",
      liquid: LIQUID_FILE_TYPES.map { |type| "#{type}.liquid" },
      schema: "schema.json",
      stylesheet: "style.css",
      javascript: "index.js",
      stimulus: "controller.js"
    }.freeze
    SUPPORTED_VALUES = SUPPORTED_FILES.values.flatten.freeze

    def initialize(file:, event:)
      @file = file.gsub("#{Dir.pwd}/", "")
      @event = event
      @contents = +""
      @logger = Logger.new($stdout)
    end

    def process
      return unless processable?

      compile_content

      File.write(compiled_filename, @contents.lstrip)

      compiled_filename
    end

    private

    # Returns true if the file is processable, false otherwise.
    def processable?
      supported? && correct_liquid_file? && correct_filename?
    end

    # Checks if the file is in the list of supported files.
    def supported?
      unless SUPPORTED_VALUES.include?(file_name)
        @logger.error "Skipping unsupported file: #{@file}"
        return false
      end

      true
    end

    # Checks if there is exactly one liquid file in the directory.
    def correct_liquid_file?
      if liquid_files.empty?
        @logger.error "No liquid file found in #{file_dir}"
        return false
      end

      if liquid_files.size > 1
        @logger.error "Multiple liquid files found in #{file_dir}"
        return false
      end

      true
    end

    # Checks if the compiled filename is valid.
    def correct_filename?
      if compiled_filename.nil?
        @logger.error(
          "Invalid file name for file: #{@file}\nProbably because the file is directly under the components folder."
        )

        return false
      end

      true
    end

    def file_name
      @file_name ||= File.basename(@file)
    end

    def file_dir
      @file_dir ||= File.dirname(@file)
    end

    # Returns an array of liquid files in the directory.
    def liquid_files
      @liquid_files ||= Dir.glob(LIQUID_FILE_TYPES.map { |type| "#{file_dir}/#{type}.liquid" })
    end

    def liquid_file
      @liquid_file ||= liquid_files.first
    end

    def liquid_file_type
      @liquid_file_type ||= File.basename(liquid_file, ".liquid")
    end

    # Returns the compiled filename based on the component name and liquid file type.
    # Example: _folder_to_watch/button/section.liquid -> sections/button.liquid
    def compiled_filename
      filename_arr = file_dir.split(File::SEPARATOR) # Split the directory path into an array.
      filename_arr = filename_arr.drop(1) # Remove the base components folder from the path. E.g., _components
      filename_arr -= LIQUID_FILE_TYPES # Remove liquid file types from the path. E.g., section, snippet, block
      filename_arr -= LIQUID_FILE_TYPES.map { |type| "#{type}s" } # Remove pluralized liquid file types from the path.
      filename = filename_arr.join("--") # Join remaining parts with '--'. E.g., button--subbutton

      return nil if filename.empty?

      "#{liquid_file_type}s/#{filename}.liquid"
    end

    # Compiles the content by aggregating various related files.
    def compile_content
      SUPPORTED_FILES.except(:stimulus).each_key do |key|
        @contents << formatted_content(key)
      end
    end

    # Returns the formatted content for a given content type.
    # For liquid, it returns the raw content.
    # For others, it wraps the content in appropriate Liquid tags.
    # E.g., {% schema %}...{% endschema %}
    # If the file does not exist, it returns an empty string.
    # If there is a default content method defined, it includes that content as well.
    # E.g., for comment, it includes a default comment about the source file.
    def formatted_content(content_type)
      content_type_file = content_type == :liquid ? liquid_file : "#{file_dir}/#{SUPPORTED_FILES[content_type]}"

      content = respond_to?("default_#{content_type}", true) ? send("default_#{content_type}") : ""
      content += file_content(content_type_file) if File.exist?(content_type_file)

      return "" if content.empty?
      return content if content_type == :liquid

      "\n{% #{content_type} %}#{content}{% end#{content_type} %}\n"
    end

    def file_content(file)
      content = File.read(file).strip
      content.empty? ? "" : "\n#{content}\n"
    end

    def default_comment
      "\n------------------------------------------------------------\n\
IMPORTANT: The contents of this file are auto-generated.\n\
Avoid editing this file directly.\n\n\
Compiled from #{liquid_file}\n\
------------------------------------------------------------\n"
    end
  end
end
