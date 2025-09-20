# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Init do
  before do
    allow($stdout).to receive(:puts)
  end

  describe "init" do
    context "first time" do
      before do
        allow(File).to receive(:exist?).and_return(false)
      end

      it "creates default files and Git configuration" do
        expect(FileUtils).to receive(:mkdir_pp).with(".gotsha/hooks")
        expect(FileUtils).to receive(:mkdir_p).with(".gotsha")

        expect(File).to receive(:write).with(Gotsha::CONFIG_FILE, File.read(Gotsha::CONFIG_TEMPLATE_PATH))
        expect(File).to receive(:write).with(Gotsha::GH_CONFIG_FILE, File.read(Gotsha::GH_CONFIG_TEMPLATE_PATH))

        expect(FileUtils).to receive(:cp).with(anything, ".gotsha/hooks/pre-push")
        expect(FileUtils).to receive(:cp).with(anything, ".gotsha/hooks/post-commit")

        expect(FileUtils).to receive(:chmod).with("+x", ".gotsha/hooks/pre-push")
        expect(FileUtils).to receive(:chmod).with("+x", ".gotsha/hooks/post-commit")

        expect(Kernel).to receive(:system).with("git config --local core.hooksPath .gotsha/hooks")

        described_class.new.call
      end
    end

    context "second time" do
      before do
        allow(File).to receive(:exist?).and_return(true)
      end

      it "creates default files and Git configuration" do
        expect(FileUtils).to receive(:mkdir_p).with(".gotsha/hooks")
        expect(FileUtils).not_to receive(:mkdir_p).with(".gotsha")

        expect(File).not_to receive(:write).with(Gotsha::CONFIG_FILE, File.read(Gotsha::CONFIG_TEMPLATE_PATH))
        expect(File).to receive(:write).with(Gotsha::GH_CONFIG_FILE, File.read(Gotsha::GH_CONFIG_TEMPLATE_PATH))

        expect(FileUtils).not_to receive(:cp).with(anything, ".gotsha/hooks/pre-push")
        expect(FileUtils).not_to receive(:cp).with(anything, ".gotsha/hooks/post-commit")

        expect(FileUtils).not_to receive(:chmod).with("+x", ".gotsha/hooks/pre-push")
        expect(FileUtils).not_to receive(:chmod).with("+x", ".gotsha/hooks/post-commit")

        expect(Kernel).to receive(:system).with("git config --local core.hooksPath .gotsha/hooks")

        described_class.new.call
      end
    end
  end
end
