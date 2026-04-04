# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Fetch do
  describe "fetch" do
    let(:git_command_mock) { double("git", success?: true) }

    before do
      allow(Gotsha::RemoteResolver).to receive(:resolve).and_return(remote_name)
    end

    context "with default remote" do
      let(:remote_name) { "origin" }

      it "calls the Git command to fetch notes" do
        expect(Gotsha::BashCommand)
          .to receive(:silent_run!)
          .with("git fetch --force origin 'refs/notes/gotsha:refs/notes/gotsha'")
          .and_return(git_command_mock)

        expect(described_class.new.call).to eq("fetched")
      end
    end

    context "with custom remote" do
      let(:remote_name) { "upstream" }

      it "uses the resolved remote" do
        expect(Gotsha::BashCommand)
          .to receive(:silent_run!)
          .with("git fetch --force upstream 'refs/notes/gotsha:refs/notes/gotsha'")
          .and_return(git_command_mock)

        expect(described_class.new.call).to eq("fetched")
      end
    end

    context "when remote notes ref does not exist" do
      let(:remote_name) { "origin" }

      it "does not fail" do
        expect(Gotsha::BashCommand)
          .to receive(:silent_run!)
          .with("git fetch --force origin 'refs/notes/gotsha:refs/notes/gotsha'")
          .and_return(double("git", success?: false, text_output: "fatal: couldn't find remote ref refs/notes/gotsha"))

        expect(described_class.new.call).to eq("fetched")
      end
    end
  end
end
