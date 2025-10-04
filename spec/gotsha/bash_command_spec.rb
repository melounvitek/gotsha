# frozen_string_literal: true

RSpec.describe Gotsha::BashCommand do
  describe ".run!" do
    let(:pid)    { 123 }
    let(:reader) { StringIO.new("hello\nworld\n") }
    let(:status) { instance_double(Process::Status, success?: true) }

    before do
      io = StringIO.new("hello\nworld\n")
      allow(io).to receive(:each).and_call_original
      allow(io).to receive(:pid).and_return(pid)

      allow(IO).to receive(:popen).and_return(io)
      allow(Process).to receive(:wait2).with(pid).and_return([nil, status])
    end

    context "when verbose output disabled" do
      before { allow(Gotsha::UserConfig).to receive(:get).with(:verbose).and_return(false) }

      it "returns collected stdout and successful status" do
        result = described_class.run!("echo test")

        expect(result.text_output).to eq("hello\nworld")
        expect(result.success?).to be(true)
      end
    end

    context "when verbose output enabled" do
      before { allow(Gotsha::UserConfig).to receive(:get).with(:verbose).and_return(true) }

      it "prints command and output, and returns the result" do
        expect { described_class.run!("echo test") }
          .to output(/echo test\nhello\nworld\n/)
          .to_stdout_from_any_process
      end
    end
  end

  describe ".silent_run!" do
    context "when verbose output disabled" do
      before { allow(Gotsha::UserConfig).to receive(:get).with(:verbose).and_return(false) }

      let(:command) { "ls" }

      it "calls `.run!` with output silencing" do
        expect(described_class).to receive(:run!).with("#{command} 2>&1")

        described_class.silent_run!(command)
      end
    end

    context "when verbose output enabled" do
      before { allow(Gotsha::UserConfig).to receive(:get).with(:verbose).and_return(true) }

      let(:command) { "ls" }

      it "calls `.run!` with the same command" do
        expect(described_class).to receive(:run!).with(command)

        described_class.silent_run!(command)
      end
    end
  end
end
