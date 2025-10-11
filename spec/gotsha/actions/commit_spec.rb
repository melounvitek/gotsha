# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Commit do
  describe "commit" do
    it "creates a blank commit and triggers `test` on it" do
      expect(Gotsha::BashCommand)
        .to receive(:silent_run!)
        .with("git -c core.hooksPath=/dev/null commit --allow-empty -m \"Run Gotsha\"")

      expect_any_instance_of(Gotsha::Actions::Test).to(receive(:call))

      described_class.new.call
    end
  end
end
