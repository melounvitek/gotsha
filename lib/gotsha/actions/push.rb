# frozen_string_literal: true

module Gotsha
  module Actions
    class Push
      DESCRIPTION = "pushes Gotsha test results to remote"

      def call
        try_push = push_command

        unless try_push.success?
          Fetch.new.call
          push_command
        end

        "pushed"
      end

      private

      def push_command
        BashCommand.silent_run!("git push --no-verify origin refs/notes/gotsha:refs/notes/gotsha")
      end
    end
  end
end
