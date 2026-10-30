# frozen_string_literal: true

require "bundler/gem_tasks"
require "fileutils"
require "minitest/test_task"
require "rbconfig"
require "rubocop/rake_task"
require "yard"
require "branchproof/rake_task"

ROOT = File.expand_path(__dir__)

Minitest::TestTask.create
RuboCop::RakeTask.new

# Wipe doc/ first so deleted classes leave no stale Markdown behind.
YARD::Rake::YardocTask.new do |task|
  task.before = -> { FileUtils.rm_rf(File.join(ROOT, "doc")) }
end

desc "Generate Markdown API documentation and the LLM index"
task docs: :yard do
  sh RbConfig.ruby, File.join(ROOT, "bin/generate_llm.rb")
end

# Reports decisions in lib/ that the tests do not fully exercise.
Branchproof::RakeTask.new(:branchproof) do |task|
  task.sources = ["lib/**/*.rb"]
  task.project = "ruby"
  task.framework = "minitest"
  task.missing_only = true
  task.minimum = %w[decision=100 mcdc=100 decision_table=100]
end

task default: %i[test rubocop]
