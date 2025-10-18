# frozen_string_literal: true

module Gotsha
  module Actions
    class Commit
      DESCRIPTION = "creates a dummy commit and runs tests on it (use for manual sign-off, if you disable hooks)"

      def call
        BashCommand.silent_run!('git -c core.hooksPath=/dev/null commit --allow-empty -m "Run Gotsha"')

        Test.new.call
      end
    end
  end
end
