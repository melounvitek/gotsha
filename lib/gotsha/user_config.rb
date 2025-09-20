# frozen_string_literal: true

module Gotsha
  class UserConfig
    def self.get(key)
      config = YAML.load_file(Config::CONFIG_FILE).transform_keys(&:to_sym)

      config[key]
    end

    def self.blank?
      config = YAML.load_file(Config::CONFIG_FILE).transform_keys(&:to_sym)

      config.empty?
    end
  end
end
