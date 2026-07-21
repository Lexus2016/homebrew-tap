class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.7.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.7.0/llm-security-proxy-v0.7.0-aarch64-apple-darwin.tar.gz"
      sha256 "943edaf84215f2964ac87c27de460a0ce1c4d1c31b4c4e076e3bfb7186102c2a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.7.0/llm-security-proxy-v0.7.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "66723cba668c9005c7a9b9cd8f68fc4f99010538b0dd6d05288dc043054bf6dd"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.7.0/llm-security-proxy-v0.7.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "28ad3d9953ba897939f556964ea97f750c37bb8f9453a211a2e63309385299b4"
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
