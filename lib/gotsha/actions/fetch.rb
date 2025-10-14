# frozen_string_literal: true

module Gotsha
  module Actions
    class Fetch
      DESCRIPTION = "fetches Gotsha test results from remote"

      def call
        command = BashCommand.silent_run!("git fetch origin 'refs/notes/gotsha:refs/notes/gotsha'")

        raise(Errors::HardFail, "something went wrong") unless command.success?

        "fetched"
      end
    end
  end
end
