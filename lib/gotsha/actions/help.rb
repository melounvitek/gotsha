# frozen_string_literal: true

module Gotsha
  module Actions
    class Help
      DESCRIPTION = "shows available commands and some tips"

      def call
        [
          "help",
          commands,
          config_file,
          contact
        ].join("\n\n")
      end

      private

      def commands
        commands = Gotsha::Actions.constants.map do |command|
          name = command.downcase
          description = Kernel.const_get("Gotsha::Actions::#{command}::DESCRIPTION")

          "gotsha #{name}   # #{description}"
        end.sort.join("\n")

        "Available commands: \n\n#{commands}\n"
      end

      def config_file
        [
          "Config file:",
          "How and when Gotsha runs tests is configured in `#{Config::CONFIG_FILE}` file, so it's the most important file to check and understand! Luckily, it's brief and contains explaining comments. If you deleted the comments it was originally generated with, or you're not sure how to set it, see https://github.com/melounvitek/gotsha/blob/master/lib/gotsha/templates/config.toml\n"
        ].join("\n\n")
      end

      def contact
        [
          "Contact:",
          "Is something not clear? Did you find a bug? Would you use new feature? Let's talk!",
          "Freel free to email me (vitek@meloun.info), or create an issue (https://github.com/melounvitek/gotsha/issues/)"
        ]
      end
    end
  end
end
