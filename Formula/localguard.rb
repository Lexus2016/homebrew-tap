class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.8.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.1/llm-security-proxy-v0.8.1-aarch64-apple-darwin.tar.gz"
      sha256 "2f66afacc9d1d3725f9e4f60d55332a491ba792736eeb3841819f9dc1a85eaab"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.1/llm-security-proxy-v0.8.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "7eab59c2571cc39021aa944574ae673af69c1a3a7dfe7ffe94fc85d0cc2ee19c"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.1/llm-security-proxy-v0.8.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "cf98628e8cfed027a5be993c41379ab030504d5b748a5d27011abe6d5dd6a78f"
    end
  end

  def install
    bin.install "llm-security-proxy"
    # Brand-friendly command name: README and localguard.me use `localguard`.
    # Keep the legacy `llm-security-proxy` name working too.
    bin.install_symlink bin/"llm-security-proxy" => "localguard"
    # Install NER models if present in the archive
    (share/"localguard/models").install Dir["models/*"] if File.directory?("models")
  end

  def post_install
    # Create data directory
    (var/"llm-proxy").mkpath
    # Symlink models to expected location if not already present
    user_models = Pathname.new(Dir.home)/".llm-proxy/models"
    unless user_models.exist?
      user_models.dirname.mkpath
      user_models.make_symlink(share/"localguard/models") if (share/"localguard/models").exist?
    end
  end

  service do
    run [opt_bin/"llm-security-proxy", "start"]
    keep_alive true
    log_path var/"log/localguard.log"
    error_log_path var/"log/localguard-error.log"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/llm-security-proxy --version")
    assert_match version.to_s, shell_output("#{bin}/localguard --version")
  end
end
