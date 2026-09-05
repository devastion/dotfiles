#!/usr/bin/env bash

set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] ||
  {
    printf 'error: macOS is required\n' >&2
    exit 1
  }

USER_ID="$(id -u)"
readonly USER_ID
readonly HOME="${HOME:?HOME is not set}"

readonly CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

readonly ZDOTDIR="${ZDOTDIR:-$CONFIG_HOME/zsh}"
readonly CLAUDE_CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$CONFIG_HOME/claude}"
readonly COPILOT_HOME="${COPILOT_HOME:-$CONFIG_HOME/copilot}"

readonly STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
readonly DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
readonly CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

readonly CURL_HOME="$CONFIG_HOME/curl"
readonly HOMEBREW_PREFIX='/opt/homebrew'

readonly LAUNCH_AGENTS_DIR="$HOME/Library/LaunchAgents"
readonly LABEL="com.user.environment"
readonly PLIST_FILE="$LAUNCH_AGENTS_DIR/$LABEL.plist"
readonly DOMAIN="gui/$USER_ID"

log() {
  printf '==> %s\n' "$*"
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

xml_escape() {
  local text="$1"

  text="${text//&/&amp;}"
  text="${text//</&lt;}"
  text="${text//>/&gt;}"

  printf '%s' "$text"
}

log "Creating directories"

mkdir -p \
  "$ZDOTDIR" \
  "$CLAUDE_CONFIG_DIR" \
  "$COPILOT_HOME" \
  "$STATE_HOME" \
  "$DATA_HOME" \
  "$CACHE_HOME" \
  "$LAUNCH_AGENTS_DIR"

environment=(
  # XDG base directories
  "XDG_CACHE_HOME=$CACHE_HOME"
  "XDG_CONFIG_HOME=$CONFIG_HOME"
  "XDG_DATA_HOME=$DATA_HOME"
  "XDG_STATE_HOME=$STATE_HOME"

  # XDG user directories
  "XDG_DESKTOP_DIR=$HOME/Desktop"
  "XDG_DOCUMENTS_DIR=$HOME/Documents"
  "XDG_DOWNLOAD_DIR=$HOME/Downloads"
  "XDG_MUSIC_DIR=$HOME/Music"
  "XDG_PICTURES_DIR=$HOME/Pictures"
  "XDG_PROJECTS_DIR=$HOME/Projects"
  "XDG_PUBLICSHARE_DIR=$HOME/Public"
  "XDG_SCREENSHOTS_DIR=$HOME/Screenshots"
  "XDG_TEMPLATES_DIR=$HOME/Templates"
  "XDG_VIDEOS_DIR=$HOME/Videos"

  # Custom zsh directories
  "ZDOTDIR=$ZDOTDIR"

  # Disable Telemetry
  'DISABLE_TELEMETRY=1'
  'DO_NOT_TRACK=1'
  'FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1'
  'EXPO_NO_TELEMETRY=1'
  'GH_TELEMETRY=0'
  'NEXT_TELEMETRY_DISABLED=1'
  'RTK_TELEMETRY_DISABLED=1'
  'STORYBOOK_DISABLE_TELEMETRY=1'
  'TRIVY_DISABLE_TELEMETRY=1'

  # Follow XDG directories
  "BAT_CONFIG_PATH=$CONFIG_HOME/bat/config"

  "BUNDLE_USER_CACHE=$CACHE_HOME/bundle"
  "BUNDLE_USER_CONFIG=$CONFIG_HOME/bundle"
  "BUNDLE_USER_PLUGIN=$DATA_HOME/bundle"

  "CLAUDE_CONFIG_DIR=$CLAUDE_CONFIG_DIR"
  "COPILOT_HOME=$COPILOT_HOME"

  "COMPOSER_HOME=$CONFIG_HOME/composer"
  "COMPOSER_CACHE_DIR=$CACHE_HOME/composer"

  "CARGO_HOME=$DATA_HOME/cargo"
  "RUSTUP_HOME=$DATA_HOME/rustup"

  "CURL_HOME=$CURL_HOME"

  "FFMPEG_DATADIR=$CONFIG_HOME/ffmpeg"

  "CURSOR_CONFIG_DIR=$CONFIG_HOME/cursor"

  "DOCKER_CONFIG=$CONFIG_HOME/docker"

  "EZA_CONFIG_DIR=$CONFIG_HOME/eza"

  "GIT_CONFIG_GLOBAL=$CONFIG_HOME/git/config"

  "GNUPGHOME=$DATA_HOME/gnupg"

  "GOPATH=$DATA_HOME/go"
  "GOMODCACHE=$CACHE_HOME/go/mod"
  "GOCACHE=$CACHE_HOME/go-build"

  "INPUTRC=$CONFIG_HOME/readline/inputrc"
  "EDITRC=$CONFIG_HOME/editline/editrc"

  "LG_CONFIG_FILE=$CONFIG_HOME/lazygit/config.yml"

  "MISE_CACHE_DIR=$CACHE_HOME/mise"
  "MISE_DATA_DIR=$DATA_HOME/mise"
  "MISE_GLOBAL_CONFIG_FILE=$CONFIG_HOME/mise/config.toml"

  "NODE_REPL_HISTORY=$STATE_HOME/node_repl_history"
  "NPM_CONFIG_USERCONFIG=$CONFIG_HOME/npm/npmrc"
  "NPM_CONFIG_CACHE=$CACHE_HOME/npm"
  "NPM_CONFIG_PREFIX=$DATA_HOME/npm"
  "COREPACK_HOME=$DATA_HOME/corepack"
  "PNPM_HOME=$DATA_HOME/pnpm"
  "YARN_CACHE_FOLDER=$CACHE_HOME/yarn"
  "YARN_GLOBAL_FOLDER=$DATA_HOME/yarn"
  "BUN_INSTALL=$DATA_HOME/bun"

  "PYTHONHISTFILE=$STATE_HOME/python/history"
  "PIPX_HOME=$DATA_HOME/pipx"
  "PIPX_BIN_DIR=$DATA_HOME/pipx/bin"
  "UV_CACHE_DIR=$CACHE_HOME/uv"
  "UV_TOOL_DIR=$DATA_HOME/uv/tools"
  "UV_TOOL_BIN_DIR=$DATA_HOME/uv/bin"

  "RIPGREP_CONFIG_PATH=$CONFIG_HOME/ripgrep/config"

  "SCREENRC=$CONFIG_HOME/screen/screenrc"

  "WGETRC=$CONFIG_HOME/wget/wgetrc"

  "SQLITE_HISTORY=$STATE_HOME/sqlite/history"
  "PSQL_HISTORY=$STATE_HOME/psql/history"
  "MYSQL_HISTFILE=$STATE_HOME/mysql/history"
  "REDISCLI_HISTFILE=$STATE_HOME/redis/history"

  # Editor, locale, pager etc.
  "LANG=${LANG:-en_US.UTF-8}"
  "LC_CTYPE=${LC_CTYPE:-${LANG:-en_US.UTF-8}}"
  'EDITOR=nvim'
  'VISUAL=nvim'
  'MANPAGER=nvim +Man!'
  'PAGER=less'
  'BROWSER=open'
)

if [[ -x "$HOMEBREW_PREFIX/bin/brew" ]]; then
  environment+=(
    "HOMEBREW_PREFIX=$HOMEBREW_PREFIX"
    "HOMEBREW_CELLAR=$HOMEBREW_PREFIX/Cellar"
    "HOMEBREW_REPOSITORY=$HOMEBREW_PREFIX"
    "HOMEBREW_BUNDLE_FILE=$CONFIG_HOME/homebrew/Brewfile"

    'HOMEBREW_NO_ANALYTICS=1'
    'HOMEBREW_NO_AUTO_UPDATE=1'
    'HOMEBREW_NO_EMOJI=1'
    'HOMEBREW_NO_ENV_HINTS=1'
    'HOMEBREW_CLEANUP_MAX_AGE_DAYS=7'
    'HOMEBREW_CLEANUP_PERIODIC_FULL_DAYS=7'
    'HOMEBREW_DISPLAY_INSTALL_TIMES=1'
    'HOMEBREW_NO_ASK=1'
  )

  if [[ -f "$CURL_HOME/.curlrc" ]]; then
    environment+=("HOMEBREW_CURLRC=$CURL_HOME/.curlrc")
  fi
fi

readonly environment

setenv_commands=''

for entry in "${environment[@]}"; do
  setenv_commands+="/bin/launchctl setenv ${entry%%=*} '${entry#*=}'"$'\n'
done

readonly setenv_commands

log "Writing LaunchAgent (${#environment[@]} variables)"

cat >"$PLIST_FILE" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>

    <key>ProgramArguments</key>
    <array>
        <string>/bin/sh</string>
        <string>-c</string>
        <string>$(xml_escape "$setenv_commands")</string>
    </array>

    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>
PLIST

chmod 644 "$PLIST_FILE"

plutil -lint "$PLIST_FILE" >/dev/null ||
  die "invalid plist"

log "Reloading LaunchAgent"

launchctl bootout "$DOMAIN/$LABEL" 2>/dev/null || true
launchctl bootstrap "$DOMAIN" "$PLIST_FILE"

/bin/sh -c "$setenv_commands"

log "Verifying"

mismatched=0

for entry in "${environment[@]}"; do
  name="${entry%%=*}"
  expected="${entry#*=}"
  actual="$(launchctl getenv "$name" || true)"

  if [[ "$actual" != "$expected" ]]; then
    printf '%-32s %s\n' "$name" "expected '$expected', got '$actual'" >&2
    mismatched=$((mismatched + 1))
  fi
done

((mismatched == 0)) ||
  die "$mismatched variable(s) were not set"

echo
echo "Success. ${#environment[@]} variables exported to the GUI session."
echo
echo "Restart Terminal/iTerm/etc. to inherit the new environment."
