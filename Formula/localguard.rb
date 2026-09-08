class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.8.3"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.3/llm-security-proxy-v0.8.3-aarch64-apple-darwin.tar.gz"
      sha256 "86460c78ca028e1761a94ba5f8f3280c8f1610180d19e86810c0cbe00fe82a31"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.3/llm-security-proxy-v0.8.3-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "3d3571858c844e194840b9fd63429743b5c546352222f9432e2127e09cc2f636"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.3/llm-security-proxy-v0.8.3-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "8350aa2de465c22c4babb745c2df40cad25cb09827b519edea3f9b9e24eca87c"
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