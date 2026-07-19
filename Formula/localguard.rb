class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.6.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.5/llm-security-proxy-v0.6.5-aarch64-apple-darwin.tar.gz"
      sha256 "40cdf96bcbd77b06db957537c0dad4ff0517348db22838ac82ef71be9af08dad"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.5/llm-security-proxy-v0.6.5-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "df8c12fdcb55775de5addfd2f727083fc3f95d453ae95ca643bfc07a7a621248"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.5/llm-security-proxy-v0.6.5-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "27525f3e45f2c401104f89e65d71c41c3e0314844ab6d67c63b61208e622e42d"
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
