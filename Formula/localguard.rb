class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.6.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.1/llm-security-proxy-v0.6.1-aarch64-apple-darwin.tar.gz"
      sha256 "489702be87c6c9964e10cd0b572917a24baf5a20ad85b086e7b28cd48ea2ee06"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.1/llm-security-proxy-v0.6.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "e293083312947bcd4acbd0451edae87f4b5b7813eb1f486c45eea9124c26d1ba"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.1/llm-security-proxy-v0.6.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "cf182b648a9daaafbe060d4fd36a389d4b7bff7342ab7a09ee60d9ccff689f83"
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
