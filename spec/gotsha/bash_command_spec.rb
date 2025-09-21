# frozen_string_literal: true

RSpec.describe Gotsha::BashCommand do
  describe ".silent_run!" do
    context "verbose output disabled" do
      before do
        allow(Gotsha::UserConfig)
          .to receive(:get)
          .with(:verbose)
          .and_return(false)
      end

      let(:command) { "ls" }

      it "calls `.run!` with output silencing" do
        expect(described_class).to receive(:run!).with("#{command} 2>&1")

        described_class.silent_run!(command)
      end
    end
  end
end
