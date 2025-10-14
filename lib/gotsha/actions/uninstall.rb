# frozen_string_literal: true

module Gotsha
  module Actions
    class Uninstall
      DESCRIPTION = "removes all Gotsha files and configurations"

      def call
        puts "Removing config files..."

        File.exist?(Config::CONFIG_DIR) && FileUtils.rm_rf(Config::CONFIG_DIR)
        File.exist?(Config::GH_CONFIG_FILE) && FileUtils.rm(Config::GH_CONFIG_FILE)

        puts "Unsetting Git hooks path..."
        BashCommand.silent_run!("git config --unset core.hooksPath")

        "done"
      end
    end
  end
end
