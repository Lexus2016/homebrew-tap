class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.2.4"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.2.4/llm-security-proxy-v0.2.4-aarch64-apple-darwin.tar.gz"
      sha256 "762f9d92dd61a51b1b62807f54f19b6f91e8f852767c412aee420f419057aa01"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.2.4/llm-security-proxy-v0.2.4-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f06d5f24169ed6f780eafcd8469653eef3e59b6a816e3a1279ba97010000458f"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.2.4/llm-security-proxy-v0.2.4-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "9e9a8dcd0aa7dbd507f5fe1d219d81114f54ed8d164dd3d7d5644eef2b4312e8"
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
