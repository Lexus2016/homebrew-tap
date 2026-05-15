class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.5.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.5.0/llm-security-proxy-v0.5.0-aarch64-apple-darwin.tar.gz"
      sha256 "70e3bf9f21627df2f99d3ff8d73d966e5c7493c6bd2fd4735ff9c48b3fdac37c"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.5.0/llm-security-proxy-v0.5.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "b6654394fdf202545ca6c894f47ceb3f3ffceff2bc627197cb20795aed72d5cd"
    end
    # Linux ARM (Raspberry Pi, etc.) — temporarily removed for v0.5.0;
    # the cross-compile slot was empty on this release.  Restored in v0.5.1.
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
