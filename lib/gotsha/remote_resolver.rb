# frozen_string_literal: true

require "open3"

module Gotsha
  module RemoteResolver
    def self.resolve
      branch_name = BashCommand.run!("git branch --show-current").text_output
      return "origin" if branch_name.empty?

      push_remote = git_config("branch.#{branch_name}.pushRemote")
      return push_remote unless push_remote.empty?

      branch_remote = git_config("branch.#{branch_name}.remote")
      return branch_remote unless branch_remote.empty?

      "origin"
    end

    def self.git_config(key)
      stdout, _status = Open3.capture2("git", "config", "--get", key)
      stdout.strip
    end

    private_class_method :git_config
  end
end
