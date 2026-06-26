class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.6.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.4/llm-security-proxy-v0.6.4-aarch64-apple-darwin.tar.gz"
      sha256 "169d277cbc358a522c38098b109b273cb50b09008f44c39fcefd5f3ea94ac1c2"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.4/llm-security-proxy-v0.6.4-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "6b8ea47f0b2a8694116a502a4c8d295d6cf62c56d809dfb20576ce95c7350aa0"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.4/llm-security-proxy-v0.6.4-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "4edf4bb482b5ecc7e4f77076cd1d232b17c4cf3c8ccd9889c16f1803bfc994bc"
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
