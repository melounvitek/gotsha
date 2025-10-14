# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Push do
  let(:git_push_result) { double("git", success?: first_push_success) }

  describe "fetch" do
    let(:first_push_success) { true }

    describe "when first push works" do
      it "ends there and does not fetch from remote" do
        expect(Gotsha::BashCommand)
          .to receive(:silent_run!)
          .with("git push --no-verify origin refs/notes/gotsha:refs/notes/gotsha")
          .and_return(git_push_result)

        expect_any_instance_of(Gotsha::Actions::Fetch).not_to receive(:call)

        expect(described_class.new.call).to eq("pushed")
      end
    end

    describe "when first push fails" do
      let(:first_push_success) { false }

      it "calls fetching" do
        expect(Gotsha::BashCommand)
          .to receive(:silent_run!)
          .with("git push --no-verify origin refs/notes/gotsha:refs/notes/gotsha")
          .and_return(git_push_result)

        expect(Gotsha::BashCommand)
          .to receive(:silent_run!)
          .with("git push --no-verify origin refs/notes/gotsha:refs/notes/gotsha")

        expect_any_instance_of(Gotsha::Actions::Fetch).to receive(:call)
        expect(described_class.new.call).to eq("pushed")
      end
    end
  end
end
