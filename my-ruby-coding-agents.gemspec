# frozen_string_literal: true

require_relative "lib/my_ruby_coding_agents/version"

Gem::Specification.new do |spec|
  spec.name = "my-ruby-coding-agents"
  spec.version = MyRubyCodingAgents::VERSION
  spec.authors = ["Lucian Ghinda"]
  spec.email = ["lucianghinda@users.noreply.github.com"]
  spec.summary = "Install Ruby and Rails coding agents for Codex and Claude Code"
  spec.description = "Install shared Ruby and Rails coding agents and delegation instructions into a project."
  spec.homepage = "https://github.com/lucianghinda/my-ruby-coding-agents"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 4.0"
  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "#{spec.homepage}/tree/main"
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"
  spec.files = Dir.chdir(__dir__) do
    Dir["lib/**/*", "exe/*", "templates/**/*", "doc/**/*.md", "llms.txt",
        "README.md", "CHANGELOG.md", "LICENSE.txt"].select { |f| File.file?(f) }.sort
  end
  spec.bindir = "exe"
  spec.executables = ["my-ruby-coding-agents"]
  spec.require_paths = ["lib"]
end
