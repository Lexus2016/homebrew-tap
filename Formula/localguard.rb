class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.3.6"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.3.6/llm-security-proxy-v0.3.6-aarch64-apple-darwin.tar.gz"
      sha256 "b1ee9a23047638408c3bee89fc59710e29696c3dfa7c0bf8a170878550d01ee1"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.3.6/llm-security-proxy-v0.3.6-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "0a76fa8c4d38ecb4bb11923356aa7763b799eb9ddcbd3b8ea91af923cae36289"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.3.6/llm-security-proxy-v0.3.6-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "29b116b5d56e086ec1cee04d900ea0b4631f8d7bbc273901841fbb729754af8a"
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
