# frozen_string_literal: true

module Gotsha
  module Actions
    class Configure
      DESCRIPTION = "opens Gotsha config file"

      def call
        editor = ENV["EDITOR"]

        raise(Errors::HardFail, "please, set ENV variable `EDITOR` first") unless editor

        Kernel.system("#{editor} #{Config::CONFIG_FILE}")

        "done"
      end
    end
  end
end
