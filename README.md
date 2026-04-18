# Homebrew Tap for LocalGuard

```bash
brew tap lexus2016/tap https://github.com/Lexus2016/homebrew-tap
```

## GUI (Desktop App) — macOS

```bash
brew install --cask localguard
```

Installs LocalGuard.app to /Applications. Quarantine attribute is removed automatically — no `xattr -cr` needed.

## CLI (Command Line)

```bash
brew install localguard
```

### Start as a service (auto-start on login)

```bash
brew services start localguard
```

### Manual start

```bash
llm-security-proxy start
```

## Update

```bash
brew upgrade localguard        # CLI
brew upgrade --cask localguard  # GUI
```
