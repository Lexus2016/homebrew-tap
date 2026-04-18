class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.3.0/llm-security-proxy-v0.3.0-aarch64-apple-darwin.tar.gz"
      sha256 "58dbd4dcf8772d9184d023f8bb669b6697b2b7cc87a8a12295cb8faabf2c7bae"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.2.5/llm-security-proxy-v0.2.5-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "e7ded3a535fd283db0b19ffc957663842a6617d208bddc740d2cd51c9f69483d"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.2.5/llm-security-proxy-v0.2.5-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "934504bfd5b3e96a07abbc406f718b8a9cbc4dfc7be352d6dd3556e8019633a7"
    end
  end

  def install
    bin.install "llm-security-proxy"
    # Install NER models if present in the archive
    if File.directory?("models")
      (share/"localguard/models").install Dir["models/*"]
    end
  end

  def post_install
    # Create data directory
    (var/"llm-proxy").mkpath
    # Symlink models to expected location if not already present
    user_models = Pathname.new(Dir.home)/".llm-proxy/models"
    unless user_models.exist?
      user_models.dirname.mkpath
      if (share/"localguard/models").exist?
        user_models.make_symlink(share/"localguard/models")
      end
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
  end
end
