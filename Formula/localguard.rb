class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.4.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.4.0/llm-security-proxy-v0.4.0-aarch64-apple-darwin.tar.gz"
      sha256 "789a54471bcf57ccabbe112b5b84f74972bed94d403d217df6687647ba835624"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.4.0/llm-security-proxy-v0.4.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "37d89eb3a841446eaba2ef0ba0318c06251a7c6fd51056677e16dbcb2b29ebe7"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.4.0/llm-security-proxy-v0.4.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "e1dd73a6c4aa77e8650cdfbb2ae7542043727b157d052cb90f2e23f838639516"
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
