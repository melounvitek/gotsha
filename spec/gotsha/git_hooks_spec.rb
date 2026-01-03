# frozen_string_literal: true

RSpec.describe "Git Hooks" do
  let(:temp_config) { "/tmp/gotsha_test_config.toml" }

  after do
    File.delete(temp_config) if File.exist?(temp_config)
  end

  describe "post-commit hook grep pattern" do
    it "does not match when post_commit_tests is commented out" do
      File.write(temp_config, <<~TOML)
        # This setting is disabled
        # post_commit_tests = true
        other_setting = false
      TOML

      grep_result = `grep -qE '^[^#]*post_commit_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("1")
    end

    it "matches when post_commit_tests = true is active" do
      File.write(temp_config, <<~TOML)
        post_commit_tests = true
        other_setting = false
      TOML

      grep_result = `grep -qE '^[^#]*post_commit_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("0")
    end

    it "does not match when post_commit_tests = false" do
      File.write(temp_config, <<~TOML)
        post_commit_tests = false
        other_setting = true
      TOML

      grep_result = `grep -qE '^[^#]*post_commit_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("1")
    end

    it "does not match when post_commit_tests is in an inline comment" do
      File.write(temp_config, <<~TOML)
        other_setting = true  # post_commit_tests = true is not set here
      TOML

      grep_result = `grep -qE '^[^#]*post_commit_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("1")
    end
  end

  describe "pre-push hook grep pattern" do
    it "does not match when pre_push_tests is commented out" do
      File.write(temp_config, <<~TOML)
        # This setting is disabled
        # pre_push_tests = true
        other_setting = false
      TOML

      grep_result = `grep -qE '^[^#]*pre_push_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("1")
    end

    it "matches when pre_push_tests = true is active" do
      File.write(temp_config, <<~TOML)
        pre_push_tests = true
        other_setting = false
      TOML

      grep_result = `grep -qE '^[^#]*pre_push_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("0")
    end

    it "does not match when pre_push_tests = false" do
      File.write(temp_config, <<~TOML)
        pre_push_tests = false
        other_setting = true
      TOML

      grep_result = `grep -qE '^[^#]*pre_push_tests\\s*=\\s*true' #{temp_config}; echo $?`.strip

      expect(grep_result).to eq("1")
    end
  end
end
