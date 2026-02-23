# Permissions (macOS)

## Accessibility (for auto-paste)

Pluggo needs `Accessibility` permission only if `Çevirince otomatik yapıştır` is enabled.

Path:

- `System Settings` -> `Privacy & Security` -> `Accessibility`

If you run Pluggo from source (`swift run`), macOS may not show it nicely as a standard app entry.

You can add the binary manually:

- `/Users/ibidi/Desktop/Pluginn/.build/arm64-apple-macosx/debug/Pluginn`
- or `/Users/ibidi/Desktop/Pluginn/.build/debug/Pluginn`

If needed, add the host app too (Terminal / iTerm / Codex).

## Clipboard Access

Depending on the app you're copying from, macOS may show a clipboard/privacy prompt. Allow access so Pluggo can read and write translated text.

## Troubleshooting

- Translation works but auto-paste doesn't:
  - Accessibility permission is missing or not applied yet.
  - Restart Pluggo after granting permission.
- No translation after copy:
  - Check `Log / Hata` panel.
  - Verify provider API key and quota.
