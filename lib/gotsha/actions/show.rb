# frozen_string_literal: true

module Gotsha
  module Actions
    class Show
      def call
        command = BashCommand.run!("git notes --ref=gotsha show")

        if command.success?
          command.text_output
        else
          raise Errors::HardFail, "not verified yet"
        end
      end
    end
  end
end
