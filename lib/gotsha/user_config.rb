# frozen_string_literal: true

module Gotsha
  class UserConfig
    def self.get(key)
      config = new.to_h

      ENV["GOTSHA_#{key.to_s.upcase}"] || # this allows changing config via ENV vars
        config[key]
    end

    def self.blank?
      new.to_h.empty?
    end

    def to_h
      TomlRB.load_file(Config::CONFIG_FILE).transform_keys(&:to_sym)
    rescue Errno::ENOENT
      {}
    rescue TomlRB::ParseError => e
      raise Errors::HardFail, "Syntax error in config file\n\n#{e.message}"
    end
  end
end
