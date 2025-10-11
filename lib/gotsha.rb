# frozen_string_literal: true

require "fileutils"
require "yaml"

require_relative "gotsha/action_dispatcher"
require_relative "gotsha/actions/commit"
require_relative "gotsha/actions/init"
require_relative "gotsha/actions/run"
require_relative "gotsha/actions/show"
require_relative "gotsha/actions/status"
require_relative "gotsha/bash_command"
require_relative "gotsha/config"
require_relative "gotsha/errors"
require_relative "gotsha/user_config"
require_relative "gotsha/version"

module Gotsha
  include Config
  include Errors


  # Main entry-point: `Gotsha::ActionDispatcher.call(action_name)`
end
