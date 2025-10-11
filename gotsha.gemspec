# frozen_string_literal: true

require_relative "lib/gotsha/version"

Gem::Specification.new do |spec|
  spec.name = "gotsha"
  spec.version = Gotsha::VERSION
  spec.authors = ["Vitek Meloun"]
  spec.email = ["vitek@meloun.info"]

  spec.summary = "Gotsha: your local CI"
  spec.homepage = "https://www.gotsha.org/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/melounvitek/gotsha"
  spec.metadata["changelog_uri"] = "https://github.com/melounvitek/gotsha"

  spec.add_dependency "toml-rb", "~> 3.0"

  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
