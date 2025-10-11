# frozen_string_literal: true

module Gotsha
  module Actions
    class Show
      def call
        command = BashCommand.silent_run!("git --no-pager notes --ref=gotsha show")

        raise(Errors::HardFail, "not verified yet") unless command.success?

        gotsha_result = command.text_output

        raise(Errors::HardFail, gotsha_result) if gotsha_result.start_with?(Test::TESTS_FAILED_NOTE_PREFIX)

        gotsha_result
      end
    end
  end
end
