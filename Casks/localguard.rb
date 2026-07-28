cask "localguard" do
  version "0.7.1"
  sha256 "e9a288c0385481f0cd6921cc655866977c208e14071406f626e24de8c4df82c2"

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
