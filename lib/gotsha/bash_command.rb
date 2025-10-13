# frozen_string_literal: true

require "pty"

module Gotsha
  class BashCommand
    FORCE_OUTPUT_AFTER = 5
    MARKER = "__GOTSHA_EXIT__:"

    def self.run!(command)
      start_time = Time.now
      UserConfig.get(:verbose) && puts(command)

      stdout = +""
      exit_code = nil

      PTY.spawn("bash", "-lc", "#{command}; printf \"\\n#{MARKER}%d\\n\" $?") do |r, _w, pid|
        begin
          r.each do |line|
            if line.start_with?(MARKER)
              exit_code = line.sub(MARKER, "").to_i
              next
            end
            if UserConfig.get(:verbose) || Time.now - start_time > FORCE_OUTPUT_AFTER
              puts line
            end
            stdout << line
          end
        rescue Errno::EIO
          # PTY closes when process ends — safe to ignore
        ensure
          Process.wait(pid)
        end
      end

      final_code = exit_code || $?.exitstatus
      status = Struct.new(:exitstatus) { def success? = exitstatus.zero? }.new(final_code)
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
