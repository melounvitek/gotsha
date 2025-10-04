# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Show do
  describe "show" do
    it "runs Git notes show command" do
      expect(Gotsha::BashCommand)
        .to receive(:silent_run!)
        .with("git notes --ref=gotsha show")

      described_class.new.call
    end
  end
end
