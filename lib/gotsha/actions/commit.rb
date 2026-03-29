# frozen_string_literal: true

module Gotsha
  module Actions
    class Commit
      DESCRIPTION = "runs tests on a dummy commit for manual sign-off"

      def call
        command = BashCommand.silent_run!('git -c core.hooksPath=/dev/null commit --allow-empty -m "Run Gotsha"')

        raise Errors::HardFail, "something went wrong" unless command.success?

        Test.new.call
      end
    end
  end
end
