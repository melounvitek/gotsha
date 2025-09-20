# frozen_string_literal: true

RSpec.describe Gotsha::ActionDispatcher do
  before do
    allow($stdout).to receive(:puts)
  end


  describe "verify" do
    let(:last_sha) { "sha_test" }

    context "when last note is ok" do
      before do
        expect(Gotsha::BashCommand)
          .to receive(:run!)
          .with("git --no-pager rev-parse HEAD")
          .and_return(double("bash_response", text_output: last_sha))

        expect(Gotsha::BashCommand)
          .to receive(:run!)
          .with("git --no-pager notes --ref=gotsha show #{last_sha}")
          .and_return(double("bash_response", text_output: "ok"))
      end

      it "returns success message" do
        result = described_class.call(:verify)

        expect(result).to eq("tests passed")
      end
    end

    context "when last note is not ok" do
      before do
        expect(Gotsha::BashCommand)
          .to receive(:run!)
          .with("git --no-pager rev-parse HEAD")
          .and_return(double("bash_response", text_output: last_sha))

        expect(Gotsha::BashCommand)
          .to receive(:run!)
          .with("git --no-pager notes --ref=gotsha show #{last_sha}")
          .and_return(double("bash_response", text_output: ""))
      end

      it "raises HardFail error" do
        expect do
          described_class.call(:verify)
        end.to raise_error(Gotsha::Errors::HardFail)
      end
    end
  end
end
