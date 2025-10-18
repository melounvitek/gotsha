# frozen_string_literal: true

module Gotsha
  module Actions
    class Configure
      DESCRIPTION = "opens Gotsha config file"

      def call
        editor = ENV["EDITOR"]

        if editor.to_s.empty?
          raise(Errors::HardFail,
                "could not open config file automatically, ENV " \
                "variable `EDITOR` not set.\n\nPlease, open file" \
                "`#{Config::CONFIG_FILE}` manually.")
        end

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
