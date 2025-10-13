# frozen_string_literal: true

require "English"
require "pty"

module Gotsha
  class BashCommand
    FORCE_OUTPUT_AFTER = 5
    MARKER = "__GOTSHA_EXIT__:"

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    def self.run!(command)
      start_time = Time.now
      UserConfig.get(:verbose) && puts(command)

      stdout = +""
      exit_code = nil

      PTY.spawn("bash", "-lc", "#{command}; printf \"\\n#{MARKER}%d\\n\" $?") do |r, _w, pid|
        r.each do |line|
          if line.start_with?(MARKER)
            exit_code = line.sub(MARKER, "").to_i
            next
          end
          puts line if UserConfig.get(:verbose) || Time.now - start_time > FORCE_OUTPUT_AFTER
          stdout << line
        end
      rescue Errno::EIO
        # PTY closes when process ends — safe to ignore
      ensure
        Process.wait(pid)
      end

      final_code = exit_code || $CHILD_STATUS.exitstatus
      status = Struct.new(:exitstatus) do
        def success?
          exitstatus.zero?
        end
      end.new(final_code)
      new(stdout, status)
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength

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
