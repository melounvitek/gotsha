# frozen_string_literal: true

module Gotsha
  module Actions
    class Push
      DESCRIPTION = "pushes Gotsha test results to remote"

      def call
        BashCommand.silent_run!("git push --no-verify --force origin refs/notes/gotsha:refs/notes/gotsha")

        "pushed"
      end
    end
  end
end
