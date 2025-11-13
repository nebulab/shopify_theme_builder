# AGENTS.md

This document provides guidance for AI agents working on the ShopifyThemeBuilder Ruby gem.

## Project Overview

ShopifyThemeBuilder is a Ruby gem that provides an opinionated builder for Shopify themes with the following key features:
- Component-based nested folder structure
- Tailwind CSS integration
- Stimulus framework support
- Streamlined Shopify theme development workflow

## Project Structure

```
shopify_theme_builder/
├── lib/
│   ├── shopify_theme_builder.rb          # Main gem entry point
│   └── shopify_theme_builder/
│       └── version.rb                     # Gem version definition
├── spec/                                  # Test files
├── bin/                                   # Executable scripts
├── sig/                                   # RBS type signatures
├── Gemfile                               # Dependencies
├── Rakefile                              # Rake tasks
├── shopify_theme_builder.gemspec         # Gem specification
└── README.md                             # Project documentation
```

## Key Information

- **Language**: Ruby (>= 3.2.0 required)
- **Purpose**: Shopify theme development tooling
- **Architecture**: Component-based approach with modern frontend tools
- **License**: MIT
- **Authors**: Massimiliano Lattanzio, Nebulab Team

## Development Guidelines

### Ruby Standards
- Follow Ruby style conventions
- Maintain compatibility with Ruby 3.2+
- Follow semantic versioning for releases
- Follow Rubocop linting rules (run with `bin/rubocop`)

### Testing
- Use RSpec for testing (run with `bin/rspec`)
- Ensure all new features have corresponding tests
- Test files are located in the `spec/` directory

### Code Structure
- Main functionality should be in `lib/shopify_theme_builder/`
- Keep the main entry point (`lib/shopify_theme_builder.rb`) clean
- Use proper module namespacing under `ShopifyThemeBuilder`

### Dependencies
- Minimize external dependencies
- Consider the impact on Shopify theme development workflow
- Ensure compatibility with Tailwind CSS and Stimulus

## Common Tasks

### Adding New Features
1. Create corresponding spec files in `spec/`
2. Implement functionality in `lib/shopify_theme_builder/`
3. Update version in `lib/shopify_theme_builder/version.rb` if needed
4. Run tests with `bin/rspec`
5. Update documentation if necessary

### Development Setup
- Run `bin/setup` to install dependencies
- Use `bin/console` for interactive testing
- Install locally with `bundle exec rake install`

### Release Process
1. Run `bin/release <version>` (e.g., `bin/release 0.1.0`)
2. This will create git commit updating version in `lib/shopify_theme_builder/version.rb`, create git tags and push to RubyGems

## Context for AI Agents

When working on this project:

1. **Focus Area**: This gem is specifically for Shopify theme development, so consider:
   - Shopify Liquid templating
   - Theme file structure requirements
   - Asset compilation and optimization
   - Component organization patterns

2. **Target Users**: Developers building Shopify themes who want:
   - Better code organization
   - Modern CSS framework integration (Tailwind)
   - JavaScript framework integration (Stimulus)
   - Streamlined build processes

3. **Integration Points**: Consider how this gem interacts with:
   - Shopify CLI and development tools
   - Tailwind CSS build processes
   - Stimulus controller organization
   - Component-based architecture

4. **Best Practices**: 
   - Maintain backward compatibility
   - Provide clear error messages
   - Support different Shopify theme structures
   - Optimize for developer experience

## Repository Information

- **GitHub**: https://github.com/nebulab/shopify_theme_builder
- **Owner**: nebulab
- **Main Branch**: main
- **License**: MIT
- **Documentation**: https://github.com/nebulab/shopify_theme_builder#readme
- **Bug Reports**: https://github.com/nebulab/shopify_theme_builder/issues

## Notes

- This is currently in pre-release (version 0.1.0.pre)
- Usage instructions are still being developed
- The gem focuses on modern frontend tooling for Shopify themes
- Component-based architecture is a core principle
