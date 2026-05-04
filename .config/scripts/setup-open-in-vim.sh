#!/usr/bin/env bash
#
# setup-open-in-vim.sh
# Setup opening text/source files from Finder/Launch Services in nvim inside an
# existing tmux session in Ghostty. After running, double clicking an associated
# file in Finder will open it in a new window in your active tmux session in nvim.
#
# Re-running this script is safe — it will recreate the app bundle from scratch.

set -euo pipefail

APP="$HOME/Applications/OpenInVim.app"
BUNDLE_ID="local.open-in-vim"

# Homebrew prefix (supports both standard and custom prefixes)
BREW_PREFIX="${HOMEBREW_PREFIX:-$(brew --prefix)}"
TMUX="$BREW_PREFIX/bin/tmux"
NVIM="$BREW_PREFIX/bin/nvim"

EXTENSIONS=(
    .json .csv .md .yaml .yml .toml .txt .sh .env .conf .ini .log
    .js .jsx .ts .tsx .mjs .cjs .mts .cts
    .css .scss .sass .less
    .vue .svelte .astro
)
UTIS=(public.plain-text public.text public.source-code)

# ---- Sanity checks ----

if ! command -v brew &>/dev/null; then
    echo "Error: Homebrew not found." >&2
    exit 1
fi

if ! command -v duti &>/dev/null; then
    echo "duti not found, installing..."
    brew install duti
fi

if [ ! -d "/Applications/Ghostty.app" ]; then
    echo "Error: Ghostty.app not found in /Applications." >&2
    exit 1
fi

if [ ! -f "$TMUX" ]; then
    echo "Error: tmux not found at $TMUX. Install with: brew install tmux" >&2
    exit 1
fi

if [ ! -f "$NVIM" ]; then
    echo "Error: nvim not found at $NVIM. Install with: brew install neovim" >&2
    exit 1
fi

# ---- Build app bundle ----

echo "Creating $APP..."
rm -rf "$APP"

osacompile -o "$APP" <<EOF
on open theFiles
  repeat with theFile in theFiles
    set filePath to POSIX path of theFile
    set fileDir to do shell script "dirname " & quoted form of filePath
    do shell script "session=\$($TMUX list-clients -F '#{session_name}' | head -1); " & ¬
      "if [ -z \"\$session\" ]; then session=\$($TMUX list-sessions -F '#{session_name}' | head -1); fi; " & ¬
      "test -n \"\$session\"; " & ¬
      "exec $TMUX new-window -c " & quoted form of fileDir & " -t \"=\${session}:\" $NVIM " & quoted form of filePath
    do shell script "open -a Ghostty"
  end repeat
end open
EOF

# osacompile doesn't set a bundle ID — add it manually
/usr/libexec/PlistBuddy -c "Add :CFBundleIdentifier string $BUNDLE_ID" \
    "$APP/Contents/Info.plist" 2>/dev/null ||
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $BUNDLE_ID" \
        "$APP/Contents/Info.plist"

echo "App bundle created at $APP"

# ---- Register with Launch Services ----

echo "Registering with Launch Services..."
/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister \
    -f "$APP"

# ---- Set duti associations ----

echo "Setting file associations..."

set_handler() {
    local target="$1"

    if ! duti -s "$BUNDLE_ID" "$target" all; then
        echo "Warning: failed to set $BUNDLE_ID as handler for $target; skipping." >&2
    fi
}

for uti in "${UTIS[@]}"; do
    set_handler "$uti"
done

for ext in "${EXTENSIONS[@]}"; do
    set_handler "$ext"
done

# ---- Verify ----

echo ""
echo "Done! Verifying a few associations:"
for ext in json md yaml ts tsx jsx css vue svelte astro; do
    result=$(duti -x "$ext" 2>/dev/null | head -1)
    echo "  .$ext -> $result"
done
