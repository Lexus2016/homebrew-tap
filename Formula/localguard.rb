class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.8.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.0/llm-security-proxy-v0.8.0-aarch64-apple-darwin.tar.gz"
      sha256 "840ee3c52ebbbc56075ad8b8a5d8f1a3035fc12336c516b87c76560c1ec3ad08"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.0/llm-security-proxy-v0.8.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f88f9f06de8d2076f321c22a9befa5afeed862379630eaa26e3ce3724180b15b"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.0/llm-security-proxy-v0.8.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "41af16377a6982bbdf09e8ab030d913d91c2d1c4acd6d03df948133f28d324e8"
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
