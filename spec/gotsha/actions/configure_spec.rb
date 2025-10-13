# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Configure do
  describe "config" do
    context "without ENV['EDITOR'] set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("EDITOR").and_return(nil)
      end

      it "fails with proper error" do
        expect do
          described_class.new.call
        end.to raise_exception(
          Gotsha::Errors::HardFail,
          "please, set ENV variable `EDITOR` first"
        )
      end
    end

    context "with ENV['EDITOR'] set to `vim`" do
      let(:editor) { "vim" }

      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("EDITOR").and_return(editor)
      end

      it "issues command to open config file in the editor" do
        expect(Kernel).to receive(:system).with("#{editor} #{Gotsha::Config::CONFIG_FILE}").and_return(true)

        described_class.new.call
      end
    end
  end
end
