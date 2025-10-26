# frozen_string_literal: true

module Gotsha
  module Actions
    class Version
      DESCRIPTION = "returns Gotsha version"

      def call
        VERSION
      end
    end
  end
end
