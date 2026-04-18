# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Commit do
  describe "commit" do
    it "creates a blank commit and triggers `test` on it" do
      git_commit = double("git_commit", success?: true)

      expect(Gotsha::BashCommand)
        .to receive(:silent_run!)
        .with("git -c core.hooksPath=/dev/null commit --allow-empty -m \"Run Gotsha\"")
        .and_return(git_commit)

      expect_any_instance_of(Gotsha::Actions::Test).to(receive(:call))

      described_class.new.call
    end

    it "does not trigger `test` when the blank commit fails" do
      git_commit = double("git_commit", success?: false)

      expect(Gotsha::BashCommand)
        .to receive(:silent_run!)
        .with("git -c core.hooksPath=/dev/null commit --allow-empty -m \"Run Gotsha\"")
        .and_return(git_commit)

      expect_any_instance_of(Gotsha::Actions::Test).not_to receive(:call)

      expect do
        described_class.new.call
      end.to raise_error(Gotsha::Errors::HardFail, "something went wrong")
    end
  end
end
