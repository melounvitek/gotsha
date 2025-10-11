# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Help do
  describe "help" do
    it "returns all actions names" do
      help_text = described_class.new.call

      action_names = Gotsha::Actions.constants.map { |a| a.to_s.downcase }

      action_names.each do |action_name|
        expect(help_text).to include(action_name)
      end
    end
  end
end
