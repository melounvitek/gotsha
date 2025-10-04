# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Show do
  describe "show" do
    let(:git_command_mock) { double("git", success?: tests_content.to_s.length > 0, text_output: tests_content) }

    before do
      expect(Gotsha::BashCommand)
        .to receive(:silent_run!)
        .with("git --no-pager notes --ref=gotsha show")
        .and_return(git_command_mock)
    end

    context "when last commit test were success" do
      let(:tests_content) { "Tests passed:\n\n" }

      it "returns the result" do
        expect(described_class.new.call).to eq(tests_content)
      end
    end

    context "when last commit tests failed" do
      let(:tests_content) { "Tests failed:\n\n" }

      it "returns not verified" do
        expect do
          described_class.new.call
        end.to raise_exception(Gotsha::Errors::HardFail, tests_content)
      end
    end

    context "when last commit was not verified" do
      let(:tests_content) { nil }

      it "returns not verified" do
        expect do
          described_class.new.call
        end.to raise_exception(Gotsha::Errors::HardFail, "not verified yet")
      end
    end
  end
end
