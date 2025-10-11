# frozen_string_literal: true

module Gotsha
  module Config
    CONFIG_DIR = ".gotsha"
    CONFIG_FILE = File.join(CONFIG_DIR, "config.toml")
    CONFIG_TEMPLATE_PATH = File.expand_path("templates/config.toml", __dir__)
    GH_CONFIG_FILE = File.join(CONFIG_DIR, "github_action_example.yml")
    GH_CONFIG_TEMPLATE_PATH = File.expand_path("templates/github_action_example.yml", __dir__)
    HOOKS_TEMPLATES_DIR = File.expand_path("templates", __dir__)
    HOOKS_DIR = File.join(CONFIG_DIR, "hooks")
  end
end
