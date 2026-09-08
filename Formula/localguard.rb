class Localguard < Formula
  desc "Transparent HTTP proxy that redacts secrets before they reach LLM providers"
  homepage "https://github.com/Lexus2016/LocalGuard"
  version "0.8.2"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.2/llm-security-proxy-v0.8.2-aarch64-apple-darwin.tar.gz"
      sha256 "473598717a8929f9600708dc837f0c556e32fba4b92a6ae9badfee29738e0889"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.2/llm-security-proxy-v0.8.2-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "92bb652479216d7946fed1d265a7db0797742db4b49a3b644f18b8a3434c2fcf"
    end
    on_intel do
      url "https://github.com/Lexus2016/LocalGuard/releases/download/v0.8.2/llm-security-proxy-v0.8.2-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "c456f6e76c4973329b22f5ba3b735ba1bea3ebb21a0a3547305f43ed73f26b42"
    end
  end

  def install
    bin.install "llm-security-proxy"
    # Brand-friendly command name: README and localguard.me use `localguard`.
    # Keep the legacy `llm-security-proxy` name working too.
    bin.install_symlink bin/"llm-security-proxy" => "localguard"
    # Install NER models if present in the archive
    (share/"localguard/models").install Dir["models/*"] if File.directory?("models")
  end

  def post_install
    # Create data directory
    (var/"llm-proxy").mkpath
    # Symlink models to expected location if not already present
    user_models = Pathname.new(Dir.home)/".llm-proxy/models"
    unless user_models.exist?
      user_models.dirname.mkpath
      user_models.make_symlink(share/"localguard/models") if (share/"localguard/models").exist?
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
    assert_match version.to_s, shell_output("#{bin}/localguard --version")
  end
end