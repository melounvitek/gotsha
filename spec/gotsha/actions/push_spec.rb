# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Push do
  describe "push" do
    let(:git_push_result) { double("git", success?: true) }

    before do
      allow(Gotsha::RemoteResolver).to receive(:resolve).and_return(remote_name)
    end

    context "with default remote" do
      let(:remote_name) { "origin" }

      it "force pushes Git notes" do
        expect(Gotsha::BashCommand)
          .to receive(:silent_run!)
          .with("git push --no-verify --force origin refs/notes/gotsha:refs/notes/gotsha")
          .and_return(git_push_result)

        expect(described_class.new.call).to eq("pushed")
      end
    end

    context "with custom remote" do
      let(:remote_name) { "upstream" }

      it "uses the resolved remote" do
        expect(Gotsha::BashCommand)
          .to receive(:silent_run!)
          .with("git push --no-verify --force upstream refs/notes/gotsha:refs/notes/gotsha")
          .and_return(git_push_result)

        expect(described_class.new.call).to eq("pushed")
      end
    end
  end
end
