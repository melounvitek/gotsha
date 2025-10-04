# frozen_string_literal: true

module Gotsha
  module Actions
    class Show
      def call
        command = BashCommand.silent_run!("git --no-pager notes --ref=gotsha show")

        raise(Errors::HardFail, "not verified yet") unless command.success?

        command.text_output
      end
    end
  end
end
