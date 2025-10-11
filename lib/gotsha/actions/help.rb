# frozen_string_literal: true

module Gotsha
  module Actions
    class Help
      def call
        commands = Gotsha::Actions.constants.map(&:downcase).sort.join("\n")

        "Available commands: \n\n#{commands}"
      end
    end
  end
end
