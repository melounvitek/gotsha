# frozen_string_literal: true

RSpec.describe Gotsha::ActionDispatcher do
  before do
    allow($stdout).to receive(:puts)
  end

  describe "run" do
    context "without test command configured" do
      before do
        allow(Gotsha::Config::USER_CONFIG)
          .to receive(:fetch)
          .with("commands")
          .and_return([])
      end

      it "fails with proper error" do
        expect do
          described_class.call(:run)
        end.to raise_exception(
          Gotsha::Errors::HardFail,
          "please, define some test commands in `.gotsha/config.yml`"
        )
      end
    end

    context "with a test command configured" do
      let(:test_command) { "rails t" }
      let(:test_text_response) { "all went well" }
      let(:sha) { "test-sha" }

      before do
        allow(Gotsha::Config::USER_CONFIG)
          .to receive(:fetch)
          .with("commands")
          .and_return([test_command])

        allow(Gotsha::Config::USER_CONFIG)
          .to receive(:fetch)
          .with("interrupt_push_on_tests_failure")
          .and_return(false)
      end

      it "runs the command" do
        allow_any_instance_of(described_class)
          .to receive(:last_commit_sha)
          .and_return(sha)

        expect(Gotsha::BashCommand)
          .to receive(:run!)
          .with(test_command)
          .and_return(double("bash_response", "success?" => true, "text_output" => "test_text_response"))

        b64 = ["test_text_response"].pack("m0")
        esc = b64.gsub("'", %q('"'"'))

        expect(Gotsha::BashCommand)
          .to receive(:silent_run!)
          .with("PAGER=cat GIT_PAGER=cat sh -c 'printf %s \"#{esc}\" | base64 -d | git notes --ref=gotsha add -f -F -'")

        described_class.call(:run)
      end
    end
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
