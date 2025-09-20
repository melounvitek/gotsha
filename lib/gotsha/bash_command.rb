# frozen_string_literal: true

require "pty"

module Gotsha
  class BashCommand
    FORCE_OUTPUT_AFTER = 5

    def self.run!(command)
      start_time = Time.now

      UserConfig.get(:verbose) && puts(command)

      stdout = +""
      status = nil

      PTY.spawn(command) do |reader, _, pid|
        reader.each do |line|
          seconds_from_start = Time.now - start_time

          (UserConfig.get(:verbose) || seconds_from_start > FORCE_OUTPUT_AFTER) && puts(line)
          stdout << line
        end
      rescue Errno::EIO
        # expected when the child closes the PTY
      ensure
        _, status = Process.wait2(pid)
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
