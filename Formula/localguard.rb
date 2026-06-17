class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.6.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.0/llm-security-proxy-v0.6.0-aarch64-apple-darwin.tar.gz"
      sha256 "bf2e43b16e9a25f761f685cd4d6c9aff1eb12e966ebe2b88b91520791633433e"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.0/llm-security-proxy-v0.6.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "ee1aff7aeac58250e6077ef0eee48a272e6ecb48f9e9d1912c916ef9e57863d8"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.6.0/llm-security-proxy-v0.6.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "72d28b9b91e288e9af1f6a49828d088fb51618faec00ceb24fca595c24dc9f52"
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
