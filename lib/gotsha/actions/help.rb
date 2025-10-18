# frozen_string_literal: true

module Gotsha
  module Actions
    class Help
      DESCRIPTION = "shows available commands and some tips"

      def call(action_name = nil)
        @action_name = action_name

        [
          "help",
          commands,
          action_description,
          config_file,
          contact
        ].compact.join("\n\n")
      end

      private

      def commands
        return if @action_name

        commands = Gotsha::Actions.constants.map do |command|
          name = command.downcase
          description = Kernel.const_get("Gotsha::Actions::#{command}::DESCRIPTION")

          "gotsha #{name}   # #{description}"
        end.sort.join("\n")

        "Available commands: \n\n#{commands}\n"
      end

      def action_description
        return unless @action_name

        description = Kernel.const_get("Gotsha::Actions::#{@action_name.capitalize}::DESCRIPTION")

        "`gotsha #{@action_name}` #{description}"
      rescue NameError
        raise Errors::HardFail, "unknown command `#{@action_name}`"
      end

      def config_file
        return if @action_name

        [
          "Config file:",
          "How and when Gotsha runs tests is configured in `#{Config::CONFIG_FILE}` file, " \
          "so it's the most important file to check and understand! Luckily, it's brief " \
          "and contains explaining comments. If you deleted the comments it was originally " \
          "generated with, or you're not sure how to set it, see " \
          "https://github.com/melounvitek/gotsha/blob/master/lib/gotsha/templates/config.toml\n"
        ].join("\n\n")
      end

      def contact
        return if @action_name

        [
          "Contact:",
          "Is something not clear? Did you find a bug? Would you use new feature? Let's talk! \n" \
          "Freel free to email me (vitek@meloun.info), or create an issue (https://github.com/melounvitek/gotsha/issues/)"
        ]
      end
    end
  end
end
