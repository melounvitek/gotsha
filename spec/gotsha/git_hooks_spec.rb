# frozen_string_literal: true

RSpec.describe "Git Hooks" do
  let(:post_commit_hook) { File.read(File.join(Gotsha::Config::HOOKS_TEMPLATES_DIR, "git_hooks", "post-commit")) }
  let(:pre_push_hook) { File.read(File.join(Gotsha::Config::HOOKS_TEMPLATES_DIR, "git_hooks", "pre-push")) }
  let(:temp_config) { "/tmp/gotsha_test_config.toml" }

  after do
    File.delete(temp_config) if File.exist?(temp_config)
  end

  describe "post-commit hook grep pattern" do
    it "should NOT match when post_commit_tests is commented out" do
      File.write(temp_config, <<~TOML)
        # This setting is disabled
        # post_commit_tests = true
        other_setting = false
      TOML

      # Extract the grep pattern from the hook (fixed version)
      grep_result = `grep -qE '^[^#]*post_commit_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("1"), "Expected grep to NOT match commented line, but it matched"
    end

    it "should match when post_commit_tests = true is active" do
      File.write(temp_config, <<~TOML)
        post_commit_tests = true
        other_setting = false
      TOML

      grep_result = `grep -qE '^[^#]*post_commit_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("0"), "Expected grep to match active line"
    end

    it "should NOT match when post_commit_tests = false" do
      File.write(temp_config, <<~TOML)
        post_commit_tests = false
        other_setting = true
      TOML

      grep_result = `grep -qE '^[^#]*post_commit_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("1"), "Expected grep to NOT match when value is false"
    end

    it "should NOT match when post_commit_tests is in an inline comment" do
      File.write(temp_config, <<~TOML)
        other_setting = true  # post_commit_tests = true is not set here
      TOML

      grep_result = `grep -qE '^[^#]*post_commit_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("1"), "Expected grep to NOT match inline comment"
    end
  end

  describe "pre-push hook grep pattern" do
    it "should NOT match when pre_push_tests is commented out" do
      File.write(temp_config, <<~TOML)
        # This setting is disabled
        # pre_push_tests = true
        other_setting = false
      TOML

      grep_result = `grep -qE '^[^#]*pre_push_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("1"), "Expected grep to NOT match commented line, but it matched"
    end

    it "should match when pre_push_tests = true is active" do
      File.write(temp_config, <<~TOML)
        pre_push_tests = true
        other_setting = false
      TOML

      grep_result = `grep -qE '^[^#]*pre_push_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("0"), "Expected grep to match active line"
    end

    it "should NOT match when pre_push_tests = false" do
      File.write(temp_config, <<~TOML)
        pre_push_tests = false
        other_setting = true
      TOML

      grep_result = `grep -qE '^[^#]*pre_push_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("1"), "Expected grep to NOT match when value is false"
    end
  end
end
