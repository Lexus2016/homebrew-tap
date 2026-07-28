class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.7.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.7.1/llm-security-proxy-v0.7.1-aarch64-apple-darwin.tar.gz"
      sha256 "b1d00fe22ce079e6effe10d228deb87fb0b86d5f608be12971559cb2aa46fb25"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.7.1/llm-security-proxy-v0.7.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c943dbfd24cc37f1d7985a61d403ce8e88b24685617dfcd8143fdd9873cbd62e"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.7.1/llm-security-proxy-v0.7.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "c9105f079d750161a901601377d038cdcd13318b0b1221710c76991a0ed1523b"
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
