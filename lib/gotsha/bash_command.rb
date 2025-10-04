# frozen_string_literal: true

require "pty"
require "shellwords"

module Gotsha
  class BashCommand
    FORCE_OUTPUT_AFTER = 5

    def self.run!(command)
      start_time = Time.now
      UserConfig.get(:verbose) && puts(command)

      stdout = +""

      wrapped = %(script -qefc #{Shellwords.escape(command)} /dev/null)

      io = IO.popen(wrapped, in: File::NULL, err: [:child, :out])
      begin
        io.each do |line|
          (UserConfig.get(:verbose) || Time.now - start_time > FORCE_OUTPUT_AFTER) && puts(line)
          stdout << line
        end
      ensure
        _, status = Process.wait2(io.pid)
      end

      new(stdout, status)
    end

    def self.silent_run!(command)
      return run!(command) if UserConfig.get(:verbose)

      run!("#{command} 2>&1")
    end

    def initialize(stdout, status)
      @stdout = stdout
      @status = status
    end

    def success?
      @status.success?
    end

    def text_output
      @stdout.to_s.strip
    end
  end
end
