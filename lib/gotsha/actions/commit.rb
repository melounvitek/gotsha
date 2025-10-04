# frozen_string_literal: true

module Gotsha
  module Actions
    class Commit
      def call
        BashCommand.silent_run!('git -c core.hooksPath=/dev/null commit --allow-empty -m "Run Gotsha"')

        Run.new.call
      end
    end
  end
end
