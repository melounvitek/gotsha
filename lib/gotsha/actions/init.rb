# frozen_string_literal: true

module Gotsha
  module Actions
    class Init
      DESCRIPTION = "first setup"

      def call
        puts "Creating files..."

        config_files!
        github_action!
        hooks!

        # TODO: I don't like this
        Kernel.system("git config --local core.hooksPath .gotsha/hooks")

        "done"
      end

      private

      def config_files!
        return if File.exist?(Config::CONFIG_FILE)

        FileUtils.mkdir_p(Config::CONFIG_DIR)

        File.write(Config::CONFIG_FILE, File.read(Config::CONFIG_TEMPLATE_PATH))
      end

      def github_action!
        return if File.exist?(Config::GH_CONFIG_FILE)

        FileUtils.mkdir_p(".github")
        FileUtils.mkdir_p(".github/workflows")
        File.write(Config::GH_CONFIG_FILE, File.read(Config::GH_CONFIG_TEMPLATE_PATH))
      end

      def hooks!
        return if File.exist?("#{Config::HOOKS_DIR}/post-commit") && File.exist?("#{Config::HOOKS_DIR}/pre-push")

        FileUtils.mkdir_p(Config::HOOKS_DIR)

        %w[post-commit pre-push].each do |hook|
          src = File.join(Config::HOOKS_TEMPLATES_DIR, "git_hooks", hook)
          dst = File.join(Config::HOOKS_DIR, hook)

          FileUtils.cp(src, dst)
          FileUtils.chmod("+x", dst)
        end
      end
    end
  end
end
