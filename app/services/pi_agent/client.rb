require "json"
require "open3"
require "timeout"

module PiAgent
  class Client
    DEFAULT_TIMEOUT_SECONDS = 30

    Result = Data.define(:text, :mode, :raw_output)

    def initialize(mode: ENV.fetch("PI_AGENT_MODE", "deterministic"))
      @mode = mode
    end

    def reply(message:, context:)
      case @mode
      when "deterministic", "fake", "test"
        Result.new(text: DeterministicReply.new(message:, context:).call, mode: "deterministic", raw_output: nil)
      when "pi"
        run_pi(message:, context:)
      else
        raise ArgumentError, "Unsupported PI_AGENT_MODE=#{@mode.inspect}"
      end
    end

    private

    def run_pi(message:, context:)
      prompt = Prompt.new(message:, context:).to_s
      command = ENV.fetch("PI_COMMAND", "pi")
      timeout_seconds = ENV.fetch("PI_AGENT_TIMEOUT_SECONDS", DEFAULT_TIMEOUT_SECONDS).to_i
      harness_dir = Rails.root.join("pi_harnesses/customer_whatsapp")

      stdout, stderr, status = nil

      Timeout.timeout(timeout_seconds) do
        stdout, stderr, status = Open3.capture3(
          { "PI_OFFLINE" => ENV.fetch("PI_OFFLINE", "0") },
          command,
          "--print",
          "--mode", "text",
          "--no-tools",
          "--no-context-files",
          "--no-skills",
          "--no-prompt-templates",
          "--append-system-prompt", harness_dir.join("APPEND_SYSTEM.md").read,
          prompt,
          chdir: harness_dir.to_s
        )
      end

      unless status.success?
        Rails.logger.warn("Pi command failed: #{stderr.to_s.truncate(500)}")
        return Result.new(
          text: "I’m sorry — the agent is unavailable right now. I can still route this to a human.",
          mode: "pi_error",
          raw_output: stdout.to_s
        )
      end

      Result.new(text: stdout.to_s.strip, mode: "pi", raw_output: stdout.to_s)
    rescue Timeout::Error
      Result.new(
        text: "I’m sorry — the agent took too long to respond. I can route this to a human.",
        mode: "pi_timeout",
        raw_output: nil
      )
    end
  end
end
