cask "localguard" do
  version "0.8.3"
  sha256 "d4953fa2cdce1da9759bcf47028f1232bea28d15f8821bc811935786d84b07cd"

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