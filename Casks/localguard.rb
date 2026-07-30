cask "localguard" do
  version "0.8.0"
  sha256 "c609a8d032f3d4b835ec7b154f3cc9808b70867dcee73e0db392b7bf10bee3fc"

  url "https://github.com/Lexus2016/LocalGuard/releases/download/v#{version}/LocalGuard_#{version}_aarch64.dmg"
  name "LocalGuard"
  desc "LLM Security Proxy — redacts secrets before they reach AI providers"
  homepage "https://github.com/Lexus2016/LocalGuard"

  depends_on macos: :catalina
  depends_on arch: :arm64

  app "LocalGuard.app"

  postflight do
    # Remove quarantine attribute so Gatekeeper doesn't block the app
    system_command "/usr/bin/xattr",
                   args: ["-cr", "#{appdir}/LocalGuard.app"],
                   sudo: false
  end

  uninstall quit: "me.localguard"

  zap trash: [
    "~/Library/Application Support/me.localguard",
    "~/.llm-proxy",
  ]
end
