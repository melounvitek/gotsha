# frozen_string_literal: true

module Gotsha
  module Actions
    class Help
      DESCRIPTION = "shows available commands"

      def call
        commands = Gotsha::Actions.constants.map do |command|
          name = command.downcase
          description = Kernel.const_get("Gotsha::Actions::#{command}::DESCRIPTION")

          "#{name}   # #{description}"
        end.sort.join("\n")

        "Available commands: \n\n#{commands}"
      end
    end
  end
end
