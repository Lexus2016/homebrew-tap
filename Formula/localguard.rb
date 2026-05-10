class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.3.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.3.4/llm-security-proxy-v0.3.4-aarch64-apple-darwin.tar.gz"
      sha256 "19680a331d5c65d2df8bf439e20067cae4f4fa0fb40afef5929137d8c95a3516"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.3.4/llm-security-proxy-v0.3.4-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "7341e9790c66a4c84f10f7c6dd21855ec14cbdaa96e7b6f52ea749830d50d881"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.3.4/llm-security-proxy-v0.3.4-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "c7f062c8075edf9f15ac8f60445bf9382a7ef41323815bfe16b9e1a4a38e98f1"
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
