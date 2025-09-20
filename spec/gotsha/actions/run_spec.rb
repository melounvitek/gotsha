# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Run do
  before do
    allow($stdout).to receive(:puts)
  end

  describe "run" do
    context "without test command configured" do
      before do
        allow(Gotsha::UserConfig)
          .to receive(:get)
          .with(:commands)
          .and_return([])
      end

      it "fails with proper error" do
        expect do
          described_class.new.call
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
        allow(Gotsha::UserConfig)
          .to receive(:get)
          .with(:commands)
          .and_return([test_command])

        allow(Gotsha::UserConfig)
          .to receive(:get)
          .with(:interrupt_push_on_tests_failure)
          .and_return(false)

        allow(Gotsha::BashCommand)
          .to receive(:run!)
          .with(test_command)
          .and_return(double("bash_response", "success?" => true, "text_output" => test_text_response))
      end

      it "runs the command" do
        b64 = ["Tests passed:\n\n#{test_text_response}"].pack("m0")
        esc = b64.gsub("'", %q('"'"'))

        expect(Gotsha::BashCommand)
          .to receive(:silent_run!)
          .with("PAGER=cat GIT_PAGER=cat sh -c 'printf %s \"#{esc}\" | base64 -d | git notes --ref=gotsha add -f -F -'")

        described_class.new.call
      end
    end
  end
end
