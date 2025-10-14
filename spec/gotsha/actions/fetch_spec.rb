# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Fetch do
  describe "fetch" do
    let(:git_command_mock) { double("git", success?: true) }

    it "calls the Git command to fetch notes" do
      expect(Gotsha::BashCommand)
        .to receive(:silent_run!)
        .with("git fetch origin 'refs/notes/gotsha:refs/notes/gotsha'")
        .and_return(git_command_mock)

      expect(described_class.new.call).to eq("fetched")
    end
  end
end
