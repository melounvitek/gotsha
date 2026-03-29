# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Fetch do
  describe "fetch" do
    let(:git_command_mock) { double("git", success?: true) }
    let(:remote_name) { "origin" }

    it "calls the Git command to fetch notes" do
      expect(Gotsha::BashCommand)
        .to receive(:run!)
        .with("git branch --show-current")
        .and_return(double("git", text_output: "main"))

      expect(Gotsha::BashCommand)
        .to receive(:run!)
        .with("git config --get branch.main.pushRemote")
        .and_return(double("git", text_output: remote_name))

      expect(Gotsha::BashCommand)
        .to receive(:silent_run!)
        .with("git fetch --force origin 'refs/notes/gotsha:refs/notes/gotsha'")
        .and_return(git_command_mock)

      expect(described_class.new.call).to eq("fetched")
    end

    it "uses branch pushRemote when configured" do
      remote_name = "upstream"

      expect(Gotsha::BashCommand)
        .to receive(:run!)
        .with("git branch --show-current")
        .and_return(double("git", text_output: "main"))

      expect(Gotsha::BashCommand)
        .to receive(:run!)
        .with("git config --get branch.main.pushRemote")
        .and_return(double("git", text_output: remote_name))

      expect(Gotsha::BashCommand)
        .to receive(:silent_run!)
        .with("git fetch --force #{remote_name} 'refs/notes/gotsha:refs/notes/gotsha'")
        .and_return(git_command_mock)

      expect(described_class.new.call).to eq("fetched")
    end

    it "does not fail when the remote notes ref does not exist yet" do
      expect(Gotsha::BashCommand)
        .to receive(:run!)
        .with("git branch --show-current")
        .and_return(double("git", text_output: "main"))

      expect(Gotsha::BashCommand)
        .to receive(:run!)
        .with("git config --get branch.main.pushRemote")
        .and_return(double("git", text_output: remote_name))

      expect(Gotsha::BashCommand)
        .to receive(:silent_run!)
        .with("git fetch --force #{remote_name} 'refs/notes/gotsha:refs/notes/gotsha'")
        .and_return(double("git", success?: false, text_output: "fatal: couldn't find remote ref refs/notes/gotsha"))

      expect(described_class.new.call).to eq("fetched")
    end
  end
end
