# frozen_string_literal: true

module Gotsha
  module Actions
    class Commit
      DESCRIPTION = "runs tests on a dummy commit for manual sign-off"

      def call
        BashCommand.silent_run!('git -c core.hooksPath=/dev/null commit --allow-empty -m "Run Gotsha"')

        Test.new.call
      end
    end
  end
end
