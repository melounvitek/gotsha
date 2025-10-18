# frozen_string_literal: true

RSpec.describe Gotsha::Actions::Help do
  describe "help" do
    context "without any argument" do
      it "returns all public actions names" do
        help_text = described_class.new.call

        action_names = Gotsha::Actions.constants.map { |a| a.to_s.downcase }

        action_names.each do |action_name|
          next if described_class::INTERNAL_ACTIONS.include?(action_name.to_sym)

          expect(help_text).to include(action_name)
        end
      end
    end

    context "with a valid action name passed" do
      let(:action_name) { "commit" }

      it "returns the action description" do
        action_description = Kernel.const_get("Gotsha::Actions::#{action_name.capitalize}::DESCRIPTION")
        help_text = described_class.new.call(action_name)

        expect(help_text).to eq("help\n\n`gotsha #{action_name}` #{action_description}")
        expect(help_text).not_to include(described_class::INTERNAL_COMMAND_WARNING)
      end
    end

    context "with a valid internal action name passed" do
      let(:action_name) { "fetch" }

      it "returns the action description with 'internal command' warning" do
        action_description = Kernel.const_get("Gotsha::Actions::#{action_name.capitalize}::DESCRIPTION")
        help_text = described_class.new.call(action_name)

        expect(help_text).to eq("help\n\n#{described_class::INTERNAL_COMMAND_WARNING}\n\n`gotsha #{action_name}` #{action_description}")
      end
    end

    context "with an unknown action name passed" do
      let(:action_name) { "rerun" }

      it "raises exception with proper message" do
        expect { described_class.new.call(action_name) }
          .to raise_exception(Gotsha::Errors::HardFail, "unknown command `#{action_name}`")
      end
    end
  end
end
