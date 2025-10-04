# frozen_string_literal: true

module Gotsha
  module Actions
    class Show
      def call
        command = BashCommand.silent_run!("git --no-pager notes --ref=gotsha show")

        raise(Errors::HardFail, "not verified yet") unless command.success?

        gotsha_result = command.text_output

        if gotsha_result.start_with?(Run::TESTS_FAILED_NOTE_PREFIX.delete("^a-zA-Z0-9 "))
          raise(Errors::HardFail, gotsha_result)
        end

        command.text_output
      end
    end
  end
end
