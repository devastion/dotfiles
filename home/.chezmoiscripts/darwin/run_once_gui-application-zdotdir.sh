#!/usr/bin/env bash

set -euo pipefail

ZDOTDIR_PATH="${ZDOTDIR:-$HOME/.config/zsh}"
CLAUDE_CONFIG_DIR_PATH="${CLAUDE_CONFIG_DIR:-$HOME/.config/claude}"
COPILOT_HOME_PATH="${COPILOT_HOME:-$HOME/.config/copilot}"
PLIST_DIR="$HOME/Library/LaunchAgents"
PLIST_FILE="$PLIST_DIR/com.user.zdotdir.plist"
LABEL="com.user.zdotdir"
USER_ID="$(id -u)"

echo "Setting up permanent ZDOTDIR..."

mkdir -p "$ZDOTDIR_PATH" "$PLIST_DIR"

cat >"$PLIST_FILE" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>${LABEL}</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <string>
          launchctl setenv ZDOTDIR ${ZDOTDIR_PATH};
          launchctl setenv CLAUDE_CONFIG_DIR ${CLAUDE_CONFIG_DIR_PATH};
          launchctl setenv COPILOT_HOME ${COPILOT_HOME_PATH};
        </string>
    </array>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
PLIST

chmod 644 "$PLIST_FILE"

plutil -lint "$PLIST_FILE" >/dev/null

launchctl bootout "gui/$USER_ID/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$USER_ID" "$PLIST_FILE"

launchctl setenv ZDOTDIR "$ZDOTDIR_PATH"
launchctl setenv CLAUDE_CONFIG_DIR "$CLAUDE_CONFIG_DIR_PATH"

echo "Success! Please restart your terminal application."
