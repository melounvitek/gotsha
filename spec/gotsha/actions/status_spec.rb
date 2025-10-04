# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Status do
  describe "status" do
    let(:last_sha) { "sha_test" }

    context "when tests ran fine" do
      before do
        expect(Gotsha::BashCommand)
          .to receive(:run!)
          .with("git --no-pager rev-parse HEAD")
          .and_return(double("bash_response", text_output: last_sha))

        expect(Gotsha::BashCommand)
          .to receive(:run!)
          .with("git --no-pager notes --ref=gotsha show #{last_sha}")
          .and_return(double("bash_response", text_output: "Tests passed:"))
      end

      it "returns success message" do
        result = described_class.new.call

        expect(result).to eq("tests passed")
      end
    end

    context "when tests failed" do
      before do
        expect(Gotsha::BashCommand)
          .to receive(:run!)
          .with("git --no-pager rev-parse HEAD")
          .and_return(double("bash_response", text_output: last_sha))

        expect(Gotsha::BashCommand)
          .to receive(:run!)
          .with("git --no-pager notes --ref=gotsha show #{last_sha}")
          .and_return(double("bash_response", text_output: "Tests failed:"))
      end

      it "raises HardFail error" do
        expect do
          described_class.new.call
        end.to raise_error(Gotsha::Errors::HardFail, "tests failed")
      end
    end

    context "when tests did not run (note with Git error message)" do
      before do
        expect(Gotsha::BashCommand)
          .to receive(:run!)
          .with("git --no-pager rev-parse HEAD")
          .and_return(double("bash_response", text_output: last_sha))

        expect(Gotsha::BashCommand)
          .to receive(:run!)
          .with("git --no-pager notes --ref=gotsha show #{last_sha}")
          .and_return(double("bash_response", text_output: "error: no note found for object"))
      end

      it "raises HardFail error" do
        expect do
          described_class.new.call
        end.to raise_error(Gotsha::Errors::HardFail, "not verified yet")
      end
    end

    context "when tests did not run (empty note)" do
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
          described_class.new.call
        end.to raise_error(Gotsha::Errors::HardFail, "not verified yet")
      end
    end
  end
end
