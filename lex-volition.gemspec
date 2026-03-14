# frozen_string_literal: true

require_relative 'lib/legion/extensions/volition/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-volition'
  spec.version       = Legion::Extensions::Volition::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'LEX Volition'
  spec.description   = 'Intention formation and drive synthesis for brain-modeled agentic AI'
  spec.homepage      = 'https://github.com/LegionIO/lex-volition'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/LegionIO/lex-volition'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-volition'
  spec.metadata['changelog_uri'] = 'https://github.com/LegionIO/lex-volition'
  spec.metadata['bug_tracker_uri'] = 'https://github.com/LegionIO/lex-volition/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob('{lib,spec}/**/*') + %w[lex-volition.gemspec Gemfile LICENSE README.md]
  end
  spec.require_paths = ['lib']
end
