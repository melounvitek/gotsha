# frozen_string_literal: true

module Gotsha
  module Actions
    class Fetch
      DESCRIPTION = "fetches Gotsha test results from remote"

      def call
        remote = RemoteResolver.resolve
        command = BashCommand.silent_run!("git fetch --force #{remote} 'refs/notes/gotsha:refs/notes/gotsha'")

        raise(Errors::HardFail, "something went wrong") unless command.success? || missing_notes_ref?(command)

        "fetched"
      end

      private

      def missing_notes_ref?(command)
        command.text_output.include?("couldn't find remote ref refs/notes/gotsha")
      end
    end
  end
end
