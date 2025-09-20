# frozen_string_literal: true

module Gotsha
  module Actions
    class Run
      def initialize
        @tests_text_outputs = []
      end

      def call
        ensure_commands_defined!
        run_commands!
        create_git_note!

        "tests passed"
      end

      private

      def ensure_commands_defined!
        return if commands.any?

        raise(Errors::HardFail,
              "please, define some test commands in `.gotsha/config.yml`")
      end

      def run_commands!
        commands.each do |command|
          puts "Running `#{command}`..."

          command_result = BashCommand.run!(command)

          @tests_text_outputs << command_result.text_output

          next if command_result.success?

          create_git_note!("Tests failed:")
          puts command_result.text_output
          raise fail_exception, "tests failed"
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
        if Config::USER_CONFIG.fetch("interrupt_push_on_tests_failure", false)
          Errors::HardFail
        else
          Errors::SoftFail
        end
      end

      def commands
        @commands ||= Array(Config::USER_CONFIG.fetch("commands"))
      end
    end
  end
end
