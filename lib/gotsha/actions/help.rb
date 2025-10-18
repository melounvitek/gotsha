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
          general_description,
          internal_command_warning,
          action_description,
          workflows_example,
          config_file,
          contact
        ].compact.join("\n\n\n")
      end

      private

      def general_description
        return if @action_name

        "About:\n" \
        "Gotsha is a tiny local CI tool — it runs your tests locally, automatically stores the " \
        "results as Git notes, and shows them right in your GitHub PR. You don’t need " \
        "to change your workflow: just use `git commit` and `git push` as usual; Gotsha takes care of the rest.\n" \
        "https://www.gotsha.org/"
      end

      def commands
        return if @action_name

        commands = Gotsha::Actions.constants.map do |command|
          name = command.downcase

          next if INTERNAL_ACTIONS.include?(name)

          description = Kernel.const_get("Gotsha::Actions::#{command}::DESCRIPTION")

          "gotsha #{name}   # #{description}"
        end.compact.sort.join("\n")

        "Available commands:\n#{commands}"
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

      def workflows_example
        return if @action_name

        [
          "Typical workflows (and their setting in config file):",
          "1. Super-fast tests (few seconds): run them automatically on every commit and push",
          "- `post_commit_tests = true`",
          "- `pre_push_tests = true`\n",
          "2. Slower but still fast (tens of seconds): run them automatically on every push, but not on each commit",
          "- `post_commit_tests = false`",
          "- `pre_push_tests = true`\n",
          "3. Even slower (or just annoying) tests: run them manually with `gotsha commit` command, right before " \
          " asking for review. Don’t allow any autorun",
          "- `post_commit_tests = false`",
          "- `pre_push_tests = false`\n"
        ].join("\n")
      end

      def config_file
        return if @action_name

        [
          "Original config file:",
          "If you deleted the explaining comments config file was " \
          "generated with and something is not clear now, see the original version here: " \
          "https://github.com/melounvitek/gotsha/blob/master/lib/gotsha/templates/config.toml"
        ].join("\n")
      end

      def contact
        return if @action_name

        [
          "Contact:",
          "Is something not clear? Did you find a bug? Would you use new feature? Let's talk! \n" \
          "Freel free to email me (vitek@meloun.info), or create an issue (https://github.com/melounvitek/gotsha/issues/)"
        ].join("\n")
      end
    end
  end
end
