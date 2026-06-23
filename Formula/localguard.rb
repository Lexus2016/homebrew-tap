class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.6.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.2/llm-security-proxy-v0.6.2-aarch64-apple-darwin.tar.gz"
      sha256 "2a944bfeb45f0f3e3892de76fc48d8efb8cb1a937fdc59c69f1c10c637d1ed2a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.2/llm-security-proxy-v0.6.2-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "bfdde7c51a46285e75a0ced2b68d013f997b02257452353ef027dac394d9e8e8"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.2/llm-security-proxy-v0.6.2-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "4eea47f00b19cf41967efb399802c6a47dd1a07a95b5c783efe931b8a5f3cd34"
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
