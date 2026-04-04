# frozen_string_literal: true

require "open3"

RSpec.describe Gotsha::RemoteResolver do
  describe ".resolve" do
    it "returns pushRemote when configured" do
      allow(Gotsha::BashCommand)
        .to receive(:run!)
        .with("git branch --show-current")
        .and_return(double("git", text_output: "main"))

      allow(Open3)
        .to receive(:capture2)
        .with("git", "config", "--get", "branch.main.pushRemote")
        .and_return(["upstream\n", double(success?: true)])

      expect(described_class.resolve).to eq("upstream")
    end

    it "falls back to remote when pushRemote is empty" do
      allow(Gotsha::BashCommand)
        .to receive(:run!)
        .with("git branch --show-current")
        .and_return(double("git", text_output: "main"))

      allow(Open3)
        .to receive(:capture2)
        .with("git", "config", "--get", "branch.main.pushRemote")
        .and_return(["", double(success?: false)])

      allow(Open3)
        .to receive(:capture2)
        .with("git", "config", "--get", "branch.main.remote")
        .and_return(["upstream\n", double(success?: true)])

      expect(described_class.resolve).to eq("upstream")
    end

    it "falls back to origin when both pushRemote and remote are empty" do
      allow(Gotsha::BashCommand)
        .to receive(:run!)
        .with("git branch --show-current")
        .and_return(double("git", text_output: "main"))

      allow(Open3)
        .to receive(:capture2)
        .with("git", "config", "--get", "branch.main.pushRemote")
        .and_return(["", double(success?: false)])

      allow(Open3)
        .to receive(:capture2)
        .with("git", "config", "--get", "branch.main.remote")
        .and_return(["", double(success?: false)])

      expect(described_class.resolve).to eq("origin")
    end

    it "returns origin on detached HEAD" do
      allow(Gotsha::BashCommand)
        .to receive(:run!)
        .with("git branch --show-current")
        .and_return(double("git", text_output: ""))

      expect(described_class.resolve).to eq("origin")
    end

    it "does not pass branch names through a shell" do
      malicious_branch = "$(whoami)"

      allow(Gotsha::BashCommand)
        .to receive(:run!)
        .with("git branch --show-current")
        .and_return(double("git", text_output: malicious_branch))

      expect(Open3)
        .to receive(:capture2)
        .with("git", "config", "--get", "branch.$(whoami).pushRemote")
        .and_return(["origin\n", double(success?: true)])

      expect(described_class.resolve).to eq("origin")
    end
  end
end
