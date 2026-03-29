# frozen_string_literal: true

module Gotsha
  module Actions
    class Fetch
      DESCRIPTION = "fetches Gotsha test results from remote"

      def call
        command = BashCommand.silent_run!("git fetch --force #{remote} 'refs/notes/gotsha:refs/notes/gotsha'")

        raise(Errors::HardFail, "something went wrong") unless command.success?

        "fetched"
      end

      private

      def remote
        branch_name = BashCommand.run!("git branch --show-current").text_output
        return "origin" if branch_name.empty?

        push_remote = BashCommand.run!("git config --get branch.#{branch_name}.pushRemote").text_output
        return push_remote unless push_remote.empty?

        branch_remote = BashCommand.run!("git config --get branch.#{branch_name}.remote").text_output
        return branch_remote unless branch_remote.empty?

        "origin"
      end
    end
  end
end
