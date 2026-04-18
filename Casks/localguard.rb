cask "localguard" do
  version "0.3.1"
  sha256 "b9d0dcd8f94c3b43c49c91664609938139a7f9d086ea8500684b83260267835d"

  url "https://github.com/Lexus2016/LocalGuard/releases/download/v#{version}/LocalGuard_#{version}_aarch64.dmg"
  name "LocalGuard"
  desc "LLM Security Proxy — redacts secrets before they reach AI providers"
  homepage "https://github.com/Lexus2016/LocalGuard"

  depends_on macos: ">= :catalina"
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
