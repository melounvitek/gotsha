# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Show do
  describe "show" do
    let(:git_text_response_mock) { "test text, does not matter here" }
    let(:git_command_mock) { double("git", success?: git_note_exists, text_output: git_text_response_mock) }

    before do
      expect(Gotsha::BashCommand)
        .to receive(:silent_run!)
        .with("git --no-pager notes --ref=gotsha show")
        .and_return(git_command_mock)
    end

    context "when last commit was verified" do
      let(:git_note_exists) { true }

      it "returns the result" do
        expect(described_class.new.call).to eq(git_text_response_mock)
      end
    end

    context "when last commit was not verified" do
      let(:git_note_exists) { false }

      it "returns the result" do
        expect do
          described_class.new.call
        end.to raise_exception(Gotsha::Errors::HardFail, "not verified yet")
      end
    end
  end
end
