# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Push do
  let(:git_push_result) { double("git", success?: true) }

  describe "push" do
    it "force pushes Git notes" do
      expect(Gotsha::BashCommand)
        .to receive(:silent_run!)
        .with("git push --no-verify --force origin refs/notes/gotsha:refs/notes/gotsha")
        .and_return(git_push_result)

      expect(described_class.new.call).to eq("pushed")
    end
  end
end
