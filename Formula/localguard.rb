class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.5.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.5.1/llm-security-proxy-v0.5.1-aarch64-apple-darwin.tar.gz"
      sha256 "8094d5ed4a4184325e37bc82b595dd710aa5ea02af7718ad7fb7fd6a7eada782"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.5.1/llm-security-proxy-v0.5.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "c38c5bc84a91188b29a615592e9d627c7d9e8b7fb01e0133f3f99cd9151cefd3"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.5.1/llm-security-proxy-v0.5.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "a8c69f608295ee0bf3af78f50cc61167e246223ee04ff2bbf17463dc667c521c"
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
