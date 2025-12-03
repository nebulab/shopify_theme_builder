# ShopifyThemeBuilder

![Gem Version](https://img.shields.io/gem/v/shopify_theme_builder?logo=rubygems)
![GitHub branch check runs](https://img.shields.io/github/check-runs/nebulab/shopify_theme_builder/main?logo=github)
![Codecov](https://img.shields.io/codecov/c/github/nebulab/shopify_theme_builder)
![Libraries.io dependency status for latest release](https://img.shields.io/librariesio/release/rubygems/shopify_theme_builder)
![Gem Total Downloads](https://img.shields.io/gem/dt/shopify_theme_builder)
![GitHub License](https://img.shields.io/github/license/nebulab/shopify_theme_builder)

ShopifyThemeBuilder is a Ruby gem that facilitates the development of Shopify themes by enabling the use of a components folder where you can organize your files and separate liquid, JSON, CSS, JavaScript, comment and doc into a dedicated file. It watches for changes in your component folder and automatically compiles all files into Shopify-compatible Liquid templates.

## What problem does it solve?

Shopify themes have a specific structure where different types of files are stored in designated folders. For example:
- Sections: Contains Liquid files that define the structure and layout of different sections of the theme.
- Blocks: Contains reusable Liquid files that can be included in sections.
- Snippets: Contains reusable Liquid files that can be included in other files.

All these files are stored in the `sections`, `blocks`, and `snippets` folders respectively and cannot be organized in subfolders.

Additionally, all files can include JSON, comments, docs, CSS and JavaScript code, which must be included in the main Liquid file, resulting in large and hard-to-maintain files.

## How does it work?

ShopifyThemeBuilder allows you to create a `components` folder (default is `_components`) where you can organize your theme files in a more modular way. Each component can have its own comments, docs, Liquid, JSON, CSS, and JavaScript files. When you run the watcher, it monitors changes in the components folder and automatically compiles the files into the appropriate Shopify theme structure. Example:

```
_components/
  button/
    comment.txt
    doc.txt
    block.liquid
    schema.json
    style.css
    index.js
blocks/
  button.liquid
```

All files inside the `button` folder will be compiled into a single `button.liquid` file in the `blocks` folder, combining the comment, doc, Liquid, JSON, CSS, and JavaScript code.

## Tailwind CSS Support

ShopifyThemeBuilder also supports Tailwind CSS integration. You can specify an input CSS file that includes Tailwind directives and an output CSS file where the compiled styles will be saved. The watcher will automatically run the Tailwind build process whenever changes are detected in the components folder.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add shopify_theme_builder --group "development"
```

## Usage

To watch for changes in the default components folder and build the theme, run:

```bash
bundle exec theme-builder watch
```

You can customize multiple options when running the watcher:
- `--folders`: Specify one or more folders to watch (default is `_components`).
- `--tailwind-input-file`: Specify the Tailwind CSS input file (default is `src/styles/tailwind.css`).
- `--tailwind-output-file`: Specify the Tailwind CSS output file (default is `assets/tailwind-output.css`).
- `--skip-tailwind`: Skip the Tailwind CSS build process (default is `false`).

If you need help with all available options, or how to set them, run:

```bash
bundle exec theme-builder help watch
```

## After Running the Watcher

The watcher will create a CSS file that can be included in your Shopify theme layout in this way:

```liquid
{{ 'tailwind-output.css' | asset_url | stylesheet_tag }}
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, run `bin/release VERSION`, which will update the version file, create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Next Steps

- [x] Run the tailwind build process automatically.
- [ ] Add Stimulus JS support.
- [ ] Create a command to build an example component with all the files.
- [ ] Decompile existing Shopify files into components structure (?).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nebulab/shopify_theme_builder.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
