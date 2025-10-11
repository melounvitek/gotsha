# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Uninstall do
  describe "uninstall" do
    it "removes config files and Git configuration" do
      expect(FileUtils).to receive(:rm_rf).with(Gotsha::Config::CONFIG_DIR)
      expect(FileUtils).to receive(:rm).with(Gotsha::Config::GH_CONFIG_FILE)
      expect(Gotsha::BashCommand).to receive(:silent_run!).with("git config --unset core.hooksPath")

      described_class.new.call
    end
  end
end
