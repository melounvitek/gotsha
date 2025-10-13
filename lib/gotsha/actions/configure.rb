# frozen_string_literal: true

module Gotsha
  module Actions
    class Configure
      DESCRIPTION = "opens Gotsha config file"

      def call
        editor = ENV["EDITOR"]

        raise(Errors::HardFail, "please, set ENV variable `EDITOR` first") unless editor

        if Kernel.system("#{editor} #{Config::CONFIG_FILE}")
          "done"
        else
          raise Errors::HardFail,
                "something went wrong, please check whether `#{editor}` editor (set in ENV variable `EDITOR`) works"
        end
      end
    end
  end
end
