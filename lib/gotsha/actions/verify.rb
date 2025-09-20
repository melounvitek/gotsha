# frozen_string_literal: true

module Gotsha
  module Actions
    class Verify
      def call
        last_commit_sha = BashCommand.run!("git --no-pager rev-parse HEAD").text_output

        last_commit_note =
          BashCommand.run!("git --no-pager notes --ref=gotsha show #{last_commit_sha}").text_output

        raise(Errors::HardFail, "not verified yet") if last_commit_note.start_with?("error: no note found") || last_commit_note.to_s.empty?
        raise(Errors::HardFail, "tests failed") if last_commit_note.start_with?("Tests failed:")
        raise(Errors::HardFail, "uknown note content") unless last_commit_note.start_with?("Tests passed:")

        "tests passed"
      end
    end
  end
end
