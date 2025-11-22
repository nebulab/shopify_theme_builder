# frozen_string_literal: true

require_relative "lib/shopify_theme_builder/version"

Gem::Specification.new do |spec|
  spec.name = "shopify_theme_builder"
  spec.version = ShopifyThemeBuilder::VERSION
  spec.authors = ["Massimiliano Lattanzio", "Nebulab Team"]
  spec.email = ["massimiliano.lattanzio@gmail.com"]

  spec.summary = "An opinionated builder for Shopify themes using nested folders, Tailwind CSS, and Stimulus."
  spec.homepage = "https://github.com/nebulab/shopify_theme_builder?tab=readme-ov-file#readme"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["bug_tracker_uri"] = "https://github.com/nebulab/shopify_theme_builder/issues"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/nebulab/shopify_theme_builder"
  spec.metadata["changelog_uri"] = "https://github.com/nebulab/shopify_theme_toolkit/releases"
  spec.metadata["rubygems_mfa_required"] = "true"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "logger", "~> 1.7"
end
