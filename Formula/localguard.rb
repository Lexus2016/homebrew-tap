class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.5.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.5.0/llm-security-proxy-v0.5.0-aarch64-apple-darwin.tar.gz"
      sha256 "b3783f3d7ae195eda5af38936b83e4674703bd1992f45610d2a5d3e1bcd29921"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.5.0/llm-security-proxy-v0.5.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "d37726e3145dd3e4ec3d6dea3b63ddde72dd106ac15901baea30480f821f5587"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.5.0/llm-security-proxy-v0.5.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "66ee396998f3cb40685efed447f73241b3ff272b533bfac1857fb21577c9db9f"
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
