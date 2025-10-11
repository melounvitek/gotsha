# frozen_string_literal: true

module Gotsha
  module Actions
    class Uninstall
      def call
        puts "Removing config files..."

        FileUtils.rmdir(Config::CONFIG_DIR)
        FileUtils.rm(Config::GH_CONFIG_FILE)

        puts "Unsetting Git hooks path..."
        BashCommand.silent_run!("git config --unset core.hooksPath")

        "done"
      end
    end
  end
end
