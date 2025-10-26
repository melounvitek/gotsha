# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Version do
  describe "version" do
    it "returns VERSION constant content" do
      expect(described_class.new.call).to eq(Gotsha::VERSION)
    end
  end
end
