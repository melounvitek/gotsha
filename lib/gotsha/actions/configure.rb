# frozen_string_literal: true

module Gotsha
  module Actions
    class Configure
      DESCRIPTION = "opens Gotsha config file"

      def call
        raise Errors::HardFail, "please, set ENV variable `EDITOR` first"
      end
    end
  end
end
