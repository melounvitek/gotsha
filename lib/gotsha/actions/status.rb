# frozen_string_literal: true

module Gotsha
  module Actions
    class Status
      def call
        last_commit_sha = BashCommand.run!("git --no-pager rev-parse HEAD").text_output

        last_commit_note =
          BashCommand.run!("git --no-pager notes --ref=gotsha show #{last_commit_sha}").text_output

        if last_commit_note.start_with?("error: no note found") || last_commit_note.to_s.empty?
          raise(Errors::HardFail,
                "not verified yet")
        end

        raise(Errors::HardFail, "tests failed") if last_commit_note.start_with?(Run::TESTS_FAILED_NOTE_PREFIX)
        raise(Errors::HardFail, "unknown note content") unless last_commit_note.start_with?(Run::TESTS_PASSED_NOTE_PREFIX)

        "tests passed"
      end
    end
  end
end
