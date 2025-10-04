# frozen_string_literal: true

module Gotsha
  module Actions
    class Init
      def call
        puts "Creating files..."

        unless File.exist?(Config::CONFIG_FILE)
          FileUtils.mkdir_p(Config::CONFIG_DIR)

          File.write(Config::CONFIG_FILE, File.read(Config::CONFIG_TEMPLATE_PATH))
        end

        File.write(Config::GH_CONFIG_FILE, File.read(Config::GH_CONFIG_TEMPLATE_PATH))

        FileUtils.mkdir_p(Config::HOOKS_DIR)

        %w[post-commit pre-push].each do |hook|
          src = File.join(Config::HOOKS_TEMPLATES_DIR, "git_hooks", hook)
          dst = File.join(Config::HOOKS_DIR, hook)

          FileUtils.cp(src, dst)
          FileUtils.chmod("+x", dst)
        end

        # TODO: this needs to go!
        Kernel.system("git config --local core.hooksPath .gotsha/hooks")

        "done"
      end
    end
  end
end
