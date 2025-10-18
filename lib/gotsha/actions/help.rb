# frozen_string_literal: true

module Gotsha
  module Actions
    class Help
      DESCRIPTION = "shows available commands and some tips (has optional <COMMAND> argument)"
      INTERNAL_ACTIONS = %i[fetch push test].freeze

      INTERNAL_COMMAND_WARNING =
        "[WARNING] This is an internal command; if everything works as intended, you should not need to run it"

      def call(action_name = nil)
        @action_name = action_name

        [
          "help",
          commands,
          internal_command_warning,
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

          next if INTERNAL_ACTIONS.include?(name)

          description = Kernel.const_get("Gotsha::Actions::#{command}::DESCRIPTION")

          "gotsha #{name}   # #{description}"
        end.compact.sort.join("\n")

        "Available commands: \n\n#{commands}\n"
      end

      def action_description
        return unless @action_name

        description = Kernel.const_get("Gotsha::Actions::#{@action_name.capitalize}::DESCRIPTION")

        "`gotsha #{@action_name}` #{description}"
      rescue NameError
        raise Errors::HardFail, "unknown command `#{@action_name}`"
      end

      def internal_command_warning
        return unless @action_name
        return unless INTERNAL_ACTIONS.include?(@action_name.to_sym)

        INTERNAL_COMMAND_WARNING
      end

      def config_file
        return if @action_name

        [
          "Original config file:",
          "If you deleted the explaining comments config file was " \
          "generated with and something is not clear now, see the original version here: " \
          "https://github.com/melounvitek/gotsha/blob/master/lib/gotsha/templates/config.toml\n",
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
