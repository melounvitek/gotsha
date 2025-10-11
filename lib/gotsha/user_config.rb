# frozen_string_literal: true

module Gotsha
  class UserConfig
    def self.get(key)
      config = TomlRB.load_file(Config::CONFIG_FILE).transform_keys(&:to_sym)

      ENV["GOTSHA_#{key.to_s.upcase}"] || # this allows changing config via ENV vars
        config[key]
    rescue Errno::ENOENT
      nil
    end

    def self.blank?
      TomlRB.load_file(Config::CONFIG_FILE).empty?
    rescue Errno::ENOENT
      true
    end
  end
end
