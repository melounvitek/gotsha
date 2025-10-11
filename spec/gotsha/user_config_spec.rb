# frozen_string_literal: true

RSpec.describe Gotsha::UserConfig do
  describe "when the config file does not exists" do
    before do
      stub_const "Gotsha::Config::CONFIG_FILE", "not/exists"
    end

    it "does not raise any exception" do
      expect(described_class.blank?).to eq(true)
      expect(described_class.get(:key)).to eq(nil)
    end
  end

  describe "when config file exists" do
    let(:config_content) do
      { "test_key" => "test_value" }
    end

    before do
      allow(TomlRB)
        .to receive(:load_file)
        .with(Gotsha::Config::CONFIG_FILE)
        .and_return(config_content)
    end

    it "returns the content" do
      expect(described_class.blank?).to eq(false)
      expect(described_class.get(:unexisting_key)).to eq(nil)
      expect(described_class.get(:test_key)).to eq("test_value")
    end
  end
end
