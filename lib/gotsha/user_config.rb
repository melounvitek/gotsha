# frozen_string_literal: true

module Gotsha
  class UserConfig
    def self.get(key)
      config = new.to_h
      env_key = "GOTSHA_#{key.to_s.upcase}"
      env_value = ENV[env_key]

      return config[key] if key.to_sym == :commands
      return coerce_env_value(env_value) unless env_value.nil?

      config[key]
    end

    def self.blank?
      new.to_h.empty?
    end

    def self.coerce_env_value(value)
      return true if value == "true"
      return false if value == "false"

      value
    end

    def to_h
      TomlRB.load_file(Config::CONFIG_FILE).transform_keys(&:to_sym)
    rescue Errno::ENOENT
      {}
    rescue TomlRB::ParseError => e
      raise Errors::HardFail, "Syntax error in config file. Open it by running `gotsha configure`\n\n#{e.message}"
    end
  end
end
