# frozen_string_literal: true

module Gotsha
  module Actions
    class Test
      DESCRIPTION = "runs and stores tests (don't use this; prefer autorun via hooks, or `gotsha commit`)"

      TESTS_PASSED_NOTE_PREFIX = "Tests passed:"
      TESTS_FAILED_NOTE_PREFIX = "Tests failed:"

      def initialize
        @tests_text_outputs = []
      end

      def call
        ensure_commands_defined!
        run_commands!
        create_git_note!(TESTS_PASSED_NOTE_PREFIX)

        "commit verified"
      end

      private

      def ensure_commands_defined!
        return if commands.any?

        raise(Errors::HardFail,
              "please, define some test commands in `.gotsha/config.toml`")
      end

      def run_commands!
        commands.each do |command|
          puts "Running `#{command}`..."

          command_result = BashCommand.run!(command)

          @tests_text_outputs << command_result.text_output

          next if command_result.success?

          create_git_note!(TESTS_FAILED_NOTE_PREFIX)
          puts command_result.text_output.split("\n").last(20).join("\n")

          raise fail_exception, "tests failed (run `gotsha show` for full output)"
        end
      end

      def create_git_note!(prefix_text = "")
        body = +""
        body << prefix_text.to_s
        body << "\n\n" unless prefix_text.to_s.empty?
        body << @tests_text_outputs.join("\n\n")

        b64 = [body].pack("m0") # base64 (no newlines)
        esc = b64.gsub("'", %q('"'"')) # escape single quotes

        BashCommand.silent_run!(
          "PAGER=cat GIT_PAGER=cat sh -c 'printf %s \"#{esc}\" | base64 -d | git notes --ref=gotsha add -f -F -'"
        )
      end

      def fail_exception
        if UserConfig.get(:interrupt_push_on_tests_failure)
          Errors::HardFail
        else
          Errors::SoftFail
        end
      end

      def commands
        @commands ||= UserConfig.get(:commands) || []
      end
    end
  end
end
