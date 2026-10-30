# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "my_ruby_coding_agents"

require "minitest/autorun"
require_relative "support/agent_fixture"
require_relative "support/installer_helpers"
require_relative "support/cli_helpers"
