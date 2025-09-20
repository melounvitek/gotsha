# frozen_string_literal: true

module Gotsha
  module Actions
    class Verify
      def call
        last_commit_sha = BashCommand.run!("git --no-pager rev-parse HEAD").text_output

        last_comment_note =
          BashCommand.run!("git --no-pager notes --ref=gotsha show #{last_commit_sha}").text_output

        raise(Errors::HardFail, "not verified yet") unless last_comment_note.length.positive?
        raise(Errors::HardFail, "tests failed") if last_comment_note.start_with?("Tests failed:")

        "tests passed"
      end
    end
  end
end
