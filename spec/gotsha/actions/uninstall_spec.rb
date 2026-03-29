# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Uninstall do
  describe "uninstall" do
    it "removes config files and Git configuration" do
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(Gotsha::Config::CONFIG_DIR).and_return(true)
      allow(File).to receive(:exist?).with(Gotsha::Config::GH_CONFIG_FILE).and_return(true)
      allow(File).to receive(:exist?).with(Gotsha::Config::GL_CONFIG_FILE).and_return(true)

      expect(FileUtils).to receive(:rm_rf).with(Gotsha::Config::CONFIG_DIR)
      expect(FileUtils).to receive(:rm).with(Gotsha::Config::GH_CONFIG_FILE)
      expect(FileUtils).to receive(:rm).with(Gotsha::Config::GL_CONFIG_FILE)
      expect(Gotsha::BashCommand).to receive(:silent_run!).with("git config --unset core.hooksPath")

      described_class.new.call
    end
  end
end
