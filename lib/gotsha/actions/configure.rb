# frozen_string_literal: true

module Gotsha
  module Actions
    class Configure
      DESCRIPTION = "opens Gotsha config file"

      def call
        binding.irb
      end
    end
  end
end
