class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.3.5"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.3.5/llm-security-proxy-v0.3.5-aarch64-apple-darwin.tar.gz"
      sha256 "7838aa21225c2418464bdfbd55fd7231add8b1934c1e2be3e7ac7172e4dbdf96"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.3.5/llm-security-proxy-v0.3.5-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "89badb0c44b5469e9f61d8629e79a15032a316996bfd8af8d42530b333e2a975"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.3.5/llm-security-proxy-v0.3.5-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "189443e967e80ac5bc5e0ca2223249e45a97cb181dc2cd2e08a48400fb3cab1f"
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
