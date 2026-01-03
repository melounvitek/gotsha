# Gotsha Bug Report

Generated: 2026-01-03

## Critical Bugs

### 1. Unhandled Git Command Failure in ActionDispatcher
**File:** `lib/gotsha/action_dispatcher.rb:38`
**Severity:** HIGH

```ruby
hooks_dir = BashCommand.run!("git config core.hooksPath").text_output
```

**Issue:** The command doesn't check if `git config` succeeds. If the config key doesn't exist or git command fails, `text_output` could contain an error message instead of a path, leading to incorrect verification logic.

**Impact:** Users might see false negatives where Gotsha claims git hooks aren't configured when they actually are, or vice versa.

**Fix:** Check command success before using output:
```ruby
command = BashCommand.run!("git config core.hooksPath")
raise(Errors::HardFail, "failed to check git config") unless command.success?
hooks_dir = command.text_output
```

---

### 2. Silent Failure in Init Command
**File:** `lib/gotsha/actions/init.rb:17`
**Severity:** HIGH

```ruby
# TODO: I don't like this
Kernel.system("git config --local core.hooksPath .gotsha/hooks")
```

**Issue:** Uses `Kernel.system` without checking the return value. If the git config command fails (e.g., not in a git repo, permissions issue), the initialization silently continues but Gotsha won't work.

**Impact:** Users complete `gotsha init` successfully but Gotsha doesn't actually work because git hooks path wasn't set.

**Fix:** Use `BashCommand.run!` for consistency and error handling:
```ruby
result = BashCommand.run!("git config --local core.hooksPath .gotsha/hooks")
raise(Errors::HardFail, "failed to configure git hooks path") unless result.success?
```

---

### 3. Potential Race Condition in BashCommand
**File:** `lib/gotsha/bash_command.rb:21-36`
**Severity:** MEDIUM

```ruby
PTY.spawn("bash", "-lc", "#{command}; printf \"\\n#{MARKER}%d\\n\" $?") do |r, _w, pid|
  r.each do |line|
    if line.start_with?(MARKER)
      exit_code = line.sub(MARKER, "").to_i
      next
    end
    # ...
  end
rescue Errno::EIO
  # PTY closes when process ends — safe to ignore
ensure
  Process.wait(pid)
end

final_code = exit_code || $CHILD_STATUS.exitstatus
```

**Issue:** If the PTY closes before the marker line is read (race condition), `exit_code` remains nil and falls back to `$CHILD_STATUS.exitstatus`. While this fallback works in most cases, the marker might not be read in all scenarios.

**Impact:** In rare cases, exit code detection could be unreliable, especially for fast-completing commands.

**Fix:** Consider more robust exit code detection or better handling of the EIO exception to ensure marker is read.

---

## High Priority Issues

### 4. Poor Error Messages in Push/Fetch
**File:** `lib/gotsha/actions/push.rb:11`, `lib/gotsha/actions/fetch.rb:11`
**Severity:** MEDIUM

```ruby
raise(Errors::HardFail, "something went wrong") unless command.success?
```

**Issue:** Generic error message doesn't help users debug what actually failed.

**Impact:** Users can't diagnose push/fetch failures (network issues, permissions, remote configuration, etc.).

**Fix:** Include actual error output:
```ruby
raise(Errors::HardFail, "push failed: #{command.text_output}") unless command.success?
```

---

### 5. Git Hooks Grep Pattern Matches Comments
**File:** `lib/gotsha/templates/git_hooks/post-commit:4`, `lib/gotsha/templates/git_hooks/pre-push:4`
**Severity:** MEDIUM

```bash
grep -qE 'post_commit_tests\s*=\s*true' .gotsha/config.toml || exit 0
```

**Issue:** This pattern will match even if the line is commented out in the TOML file. For example:
```toml
# post_commit_tests = true  # This is disabled!
```
Would incorrectly trigger the hook.

**Impact:** Hooks might run when user thinks they're disabled, or vice versa.

**Fix:** Use a TOML parser or ensure the line isn't commented:
```bash
grep -qE '^[^#]*post_commit_tests\s*=\s*true' .gotsha/config.toml || exit 0
```

---

### 6. Status Command Relies on English Error Messages
**File:** `lib/gotsha/actions/status.rb:14`
**Severity:** MEDIUM

```ruby
if last_commit_note.start_with?("error: no note found") || last_commit_note.to_s.empty?
  raise(Errors::HardFail, "not verified yet")
end
```

**Issue:** Git error messages are localized and vary by git version. This check only works for English git installations.

**Impact:** Non-English git users or different git versions might get incorrect status.

**Fix:** Check command success instead of parsing error messages:
```ruby
command = BashCommand.run!("git --no-pager notes --ref=gotsha show #{last_commit_sha}")
raise(Errors::HardFail, "not verified yet") unless command.success?
last_commit_note = command.text_output
```

---

## Medium Priority Issues

### 7. Login Shell Side Effects in BashCommand
**File:** `lib/gotsha/bash_command.rb:21`
**Severity:** LOW-MEDIUM

```ruby
PTY.spawn("bash", "-lc", "#{command}; printf \"\\n#{MARKER}%d\\n\" $?")
```

**Issue:** The `-l` flag loads the user's login shell profile (`.bash_profile`, `.profile`, etc.). This can have unexpected side effects:
- Modifies environment variables
- Changes PATH
- Executes arbitrary code from profile
- Slower startup

**Impact:** Commands might behave differently than expected based on user's shell configuration. Could also be a security concern if profile contains malicious code.

**Fix:** Consider using `bash -c` without `-l` unless login shell is specifically needed.

---

### 8. No Command Sanitization in Config
**File:** `lib/gotsha/actions/test.rb:72`
**Severity:** LOW-MEDIUM

```ruby
def commands
  @commands ||= (UserConfig.get(:commands) || []).reject(&:empty?)
end
```

**Issue:** Commands from config are executed directly without any validation or sanitization. While users control their own config, there's no warning about security.

**Impact:** Users might not realize that malicious commands in config could be dangerous, especially if they copy config from untrusted sources.

**Fix:** Add documentation warning, or consider validating commands don't contain obvious dangerous patterns.

---

### 9. Base64 Output in Test Notes Could Be Large
**File:** `lib/gotsha/actions/test.rb:55-59`
**Severity:** LOW

```ruby
b64 = [body].pack("m0") # base64 (no newlines)
esc = b64.gsub("'", %q('"'"')) # escape single quotes

BashCommand.silent_run!(
  "PAGER=cat GIT_PAGER=cat sh -c 'printf %s \"#{esc}\" | base64 -d | git notes --ref=gotsha add -f -F -'"
)
```

**Issue:** Large test outputs get base64 encoded and stored in git notes. Git notes have size limits, and very large outputs could cause issues.

**Impact:** Projects with very verbose test output might hit git note size limits or performance issues.

**Fix:** Consider truncating test output or warning users about size limits.

---

### 10. UserConfig ENV Override Doesn't Validate Types
**File:** `lib/gotsha/user_config.rb:8`
**Severity:** LOW

```ruby
ENV["GOTSHA_#{key.to_s.upcase}"] || config[key]
```

**Issue:** Environment variables are always strings, but config values can be booleans, arrays, etc. The ENV override doesn't do type coercion.

**Impact:** Setting `GOTSHA_POST_COMMIT_TESTS=true` as an env var would be the string "true", not boolean true, which could cause unexpected behavior in boolean checks.

**Fix:** Add type coercion based on expected config value types:
```ruby
env_val = ENV["GOTSHA_#{key.to_s.upcase}"]
return env_val == "true" if env_val && [true, false].include?(config[key])
env_val || config[key]
```

---

### 11. Time-Based Output Forcing Uses Wall Time
**File:** `lib/gotsha/bash_command.rb:14,27`
**Severity:** LOW

```ruby
start_time = Time.now
# ...
puts line if UserConfig.get(:verbose) || Time.now - start_time > FORCE_OUTPUT_AFTER
```

**Issue:** Uses wall clock time instead of process time. A command that's been running 10 seconds but blocked/sleeping won't show output.

**Impact:** Long-running but quiet commands might not show output when expected.

**Fix:** This is probably acceptable behavior, but could be documented.

---

## Code Quality Issues

### 12. Inconsistent Error Handling
**Files:** Multiple

**Issue:** Some commands use `BashCommand.run!` and check success, others use `silent_run!`, and Init uses `Kernel.system`. Inconsistent approaches make the code harder to maintain.

**Fix:** Standardize on `BashCommand.run!` everywhere and always check success.

---

### 13. Typo in Config Template Comment
**File:** `lib/gotsha/templates/config.toml:42`
**Severity:** TRIVIAL

```toml
#   gotsha commmit
```

**Issue:** "commmit" has three m's instead of two.

**Fix:** Change to "commit".

---

## Summary

**Critical Bugs:** 3
**High Priority:** 3
**Medium Priority:** 5
**Code Quality:** 2

**Recommended Fix Order:**
1. Fix #2 (Silent failure in Init) - blocks core functionality
2. Fix #1 (Unhandled git command failure) - causes false verification
3. Fix #6 (Status locale issue) - affects reliability
4. Fix #4 (Poor error messages) - improves debuggability
5. Fix #5 (Grep pattern) - prevents unexpected behavior
6. Fix #10 (ENV type handling) - prevents configuration bugs
7. Address remaining issues as time permits

## Testing Recommendations

After fixes, test these scenarios:
- `gotsha init` when not in a git repository
- `gotsha init` when git config fails
- Non-English git installations
- Config files with commented-out settings
- Very large test outputs
- Commands that fail vs succeed
- ENV variable overrides with different types
