#!/usr/bin/env zsh

() {
  local _index
  for _index in {1..10}; do
    alias -- "${_index}"="builtin cd -${_index}"
  done
}

unalias run-help 2> /dev/null
autoload -Uz run-help
alias help='run-help'

alias zprofile='ZSH_PROFILE=1 exec zsh'

alias cp='command cp -iv'
alias grep='command grep --color=auto'
alias ln='command ln -iv'
alias mkdir='command mkdir -pv'
alias mv='command mv -iv'

if is-callable 'trash'; then
  alias trash='command trash -v'
  alias rm='command trash -v'
fi

is-callable 'eza' && {
  alias l='command eza --group-directories-first --icons=auto --color=auto --hyperlink'
  # --long --header --binary --octal-permissions --git --smart-group --time-style=relative
  alias ll='l -lhbo --git --smart-group --time-style=relative'
  alias ls='ll -a' # short listing
  alias la='ll -A' # almost-all (skip . and ..)
  alias ld='ll --only-dirs'
  alias lf='ll --only-files'
  alias lr='ll --recurse'
  alias lh='ll -d .*' # hidden entries only
  alias l1='ls -1'
  alias lt='ls --sort=newest -r --time-style="+%Y-%m-%d %H:%M:%S"'
  alias lS='ls --total-size -S -r --sort=size'
  alias lG='l --grid'
  alias lst='l --tree --level 2'
}

alias dirs='dirs -v -l'
alias type='type -a'
alias diskspace='command df -P -kHl'

# Date/Time
alias timestamp="date '+%Y-%m-%d %H:%M:%S'"
alias datestamp="date '+%Y-%m-%d'"
alias isodate='date +%Y-%m-%dT%H:%M:%S%z'
alias utc='date -u +%Y-%m-%dT%H:%M:%SZ'
alias unixepoch='date +%s'

# Clipboard
create-alias -e -b cpwd='pwd | pbcopy'
create-alias -g -e ccat='pbcopy <' # usage: ccat <file>
create-alias -g -e -b pbp='pbpaste'
create-alias -g -e -b pbc='pbcopy'

# Networking
alias myip='curl -fsSL --max-time 5 ifconfig.me'
[[ $OSTYPE == darwin* ]] && alias localip='ipconfig getifaddr en0'

# Processes
alias psf='ps aux | grep -i' # usage: psf <name>
alias listening='lsof -i -P -n | grep LISTEN'

# Filesystem
alias df='df -h'
alias du='du -h'
alias duh='du -sh ./*'

# MacOS
alias battery='pmset -g batt'
alias mem='memory_pressure'
alias cpu='sysctl -n machdep.cpu.brand_string'
alias macos='sw_vers'
alias mute='osascript -e "set volume output muted true"'
alias unmute='osascript -e "set volume output muted false"'

# Encode/decode URL components
alias urldecode='python3 -c "import sys, urllib.parse as ul; s=sys.argv[1] if len(sys.argv)>1 else sys.stdin.read(); print(ul.unquote_plus(s.rstrip(chr(10))))"'
alias urlencode='python3 -c "import sys, urllib.parse as ul; s=sys.argv[1] if len(sys.argv)>1 else sys.stdin.read(); print(ul.quote_plus(s.rstrip(chr(10))))"'

# Development
((${+commands[yq]})) && {
  alias yq='yq --prettyPrint'
}
json-plist() plutil -convert xml1 -o - -- "${1:--}"
plist-json() plutil -convert json -r -o - -- "${1:--}"
alias json{-,2}y{a,}ml='ruby -r json -r yaml -e "puts JSON.parse(ARGF.read).to_yaml(indentation: ${TABSIZE:-2}).lines.drop 1"'
alias y{a,}ml{-,2}json='ruby -r yaml -r json -e "puts JSON.pretty_generate YAML.safe_load ARGF.read, aliases: true"'
alias v='$EDITOR'
alias nv="mise x node@lts -- nvim"
alias mx="mise x --"
alias vn="NVIM_APPNAME=nvim-next nvim"

# Hash functions
alias sha{256,}='shasum -a 256'
alias sha224='shasum -a 224'
alias md5='md5 -q'

((${+commands[tmux]})) && {
  [[ -x "${XDG_CONFIG_HOME}/tmux/scripts/switch-session" ]] &&
    alias ta="${XDG_CONFIG_HOME}/tmux/scripts/switch-session"
  alias tls='tmux ls'
  alias tkss='tmux kill-session'
  alias tksv='tmux kill-server'
}

((${+commands[chezmoi]})) && {
  # Status
  create-alias -e -b ch="chezmoi"
  create-alias -e -b chd="chezmoi diff"
  create-alias -e -b chst="chezmoi status"
  create-alias -e -b chdoc="chezmoi doctor"

  # Editing source
  create-alias -e cha="chezmoi add"
  create-alias -e -b chr="chezmoi re-add"
  create-alias -e -b che="chezmoi edit"
  create-alias -e -b chea="chezmoi edit --apply"
  create-alias -e -b chcd="chezmoi cd"

  # Updating target
  create-alias -e -b chap="chezmoi apply"
  create-alias -e -b chup="chezmoi update"
  create-alias -e -b chug="chezmoi upgrade"
}

((${+commands[npm]})) && {
  create-alias -e nr='npm run'
}

((${+commands[docker]})) && {
  dai() {
    local _cid
    if ! docker ps -q | grep -q .; then
      printf "No docker containers running!"
      return 1
    fi

    if [ -n "$1" ]; then
      _cid="$(docker ps -q --filter "name=$1" | head -n1)"
    else
      _cid="$(
        docker ps --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}" |
          fzf -1 |
          awk '{print $1}'
      )" || return 1
    fi

    if [ -z "$_cid" ]; then
      printf "Couldn't find container id"
      return 1
    fi

    docker exec -e TERM -e COLORTERM -e LC_ALL=C.UTF-8 -it "$_cid" sh -c \
      "if [ -x /bin/bash ]; then exec /bin/bash; else exec /bin/sh; fi"
  }

  dcs() {
    local -a containers=()
    while IFS='' read -r line; do containers+=("$line"); done < <(docker ps -q)
    if [ ${#containers[@]} -eq 0 ]; then
      echo "No docker containers running!"
      return 1
    fi

    echo "Stopping all docker containers..."
    docker stop -t 5 "${containers[@]}"
    echo "All docker containers are stopped!"
    return 0
  }

  create-alias -e dco='docker compose'
  create-alias -e dcoup='docker compose up --pull never'
}

is-callable 'brew' && {
  create-alias -e -d 'Remove outdated downloads and old versions' brewc='brew cleanup'
  create-alias -e -d 'Install a formula' brewi='brew install'
  create-alias -e -d 'List installed formulae that are not dependencies' brewL='brew leaves'
  create-alias -e -d 'List installed formulae' brewl='brew list'
  create-alias -e -d 'List outdated formulae' brewo='brew outdated'
  create-alias -e -d 'Search for formulae' brews='brew search'
  create-alias -e -d 'Upgrade installed formulae' brewu='brew upgrade'
  create-alias -e -d 'Uninstall a formula' brewx='brew uninstall'

  create-alias -e -d 'Install a cask' caski='brew install --cask'
  create-alias -e -d 'List installed casks' caskl='brew list --cask'
  create-alias -e -d 'List outdated casks' casko='brew outdated --cask'
  create-alias -e -d 'Search for casks' casks='brew search --cask'
  create-alias -e -d 'Upgrade installed casks' casku='brew upgrade --cask'
  create-alias -e -d 'Uninstall a cask' caskx='brew uninstall --cask'

  create-alias -e -b -d 'Update Homebrew, upgrade packages, and clean up' brewup="brew update && brew upgrade && brew cleanup"
  create-alias -e -b -d 'Show descriptions for installed formulae' brewinfo="brew leaves | xargs brew desc --eval-all"
  brewdeps() {
    emulate -L zsh
    local bluify_deps='
    BEGIN { blue = "\033[34m"; reset = "\033[0m" }
    { leaf = $1; $1 = ""; printf "%s%s%s%s\n", leaf, blue, $0, reset}
    '
    brew leaves | xargs brew deps --installed --for-each | awk "$bluify_deps"
  }
}

# Pipes (|& = 2>&1 - pipe both stdout and stderr)
create-alias -g -e -d 'Pipe stdout and stderr to column and format as a table' COL='|& column -t'
create-alias -g -e -d 'Pipe stdout and stderr to grep' G='|& grep'
create-alias -g -e -d 'Copy stdout to the clipboard' C='| pbcopy'
create-alias -g -e -d 'Remove newlines and copy stdout to the clipboard' CC='| tr -d "\n" | pbcopy'
create-alias -g -e -d 'Pipe stdout and stderr to less' L='|& less'
create-alias -g -e -d 'Pipe stdout and stderr to sort' S='|& sort'
create-alias -g -e -d 'Pipe stdout and stderr to reverse numeric sort' R='|& sort -rn'
create-alias -g -e -d 'Count lines' W='|& wc -l | sed "s/^\ *//"'
create-alias -g -e -d 'Show the first lines' H='|& head'
create-alias -g -e -d 'Show the last lines' T='|& tail'
create-alias -g -e -d 'Show the first line' H1='H -n 1'
create-alias -g -e -d 'Show the last line' T1='T -n 1'
create-alias -g -e -d 'Pipe stdout and stderr to less' LL='2>&1 | less'
create-alias -g -e -d 'Pipe stdout and stderr to cat with visible control characters' CA='2>&1 | cat -vET'
create-alias -g -e -d 'Suppress stderr' NE='2> /dev/null'
create-alias -g -e -d 'Suppress stdout and stderr' NUL='> /dev/null 2>&1'

# Glob modifiers

# Empty / directories
create-alias -g -e -d 'Zero-byte regular files' ZF='*(.L0)'
create-alias -g -e -d 'Empty directories' ZD='*(/^F)'
create-alias -g -e -d 'Non-empty directories' FD='*(F)'

# Recursive
create-alias -g -e -d 'All regular files recursively' AF='**/*(.)'
create-alias -g -e -d 'All directories recursively' AD='**/*(/)'
create-alias -g -e -d 'All symbolic links recursively' AS='**/*(@)'
create-alias -g -e -d 'All executable regular files recursively' AX='**/*(*)'
create-alias -g -e -d 'All FIFOs recursively' AP='**/*(p)'
create-alias -g -e -d 'All hidden regular files recursively' AH='**/*(.D)'

# Current directory
create-alias -g -e -d 'All entries in the current directory, including dotfiles' AE='{,.}*'

# Newest / oldest
create-alias -g -e -d 'Newest regular file' NF='*(.om[1])'
create-alias -g -e -d 'Newest directory' ND='*(/om[1])'
create-alias -g -e -d 'Newest symbolic link' NS='*(@om[1])'
create-alias -g -e -d 'Oldest regular file' OF='*(.om[-1])'
create-alias -g -e -d 'Oldest directory' OD='*(/om[-1])'
create-alias -g -e -d 'Oldest symbolic link' OS='*(@om[-1])'
create-alias -g -e -d '3 newest regular files' N3='*(.om[1,3])'
create-alias -g -e -d '10 newest regular files' N10='*(.om[1,10])'

# Modified time
create-alias -g -e -d 'Regular files modified within the last hour' MH='*(.mh-1)'
create-alias -g -e -d 'Regular files modified within the last day' MD='*(.m-1)'
create-alias -g -e -d 'Regular files modified within the last week' MW='*(.mw-1)'
create-alias -g -e -d 'Regular files older than 30 days' MO='*(.m+30)'

# Size
create-alias -g -e -d 'Largest regular file' LF='*(.OL[1])'
create-alias -g -e -d 'Smallest regular file' SF='*(.OL[-1])'
create-alias -g -e -d '10 largest regular files' L10='*(.OL[1,10])'
create-alias -g -e -d 'Regular files larger than 1 MiB' G1='*(.Lk+1024)'
create-alias -g -e -d 'Regular files smaller than 100 KiB' S1='*(.Lk-100)'

# Ownership / permissions
create-alias -g -e -d 'Files owned by the current user' ME='*(U)'
create-alias -g -e -d 'Files not owned by the current user' NM='*(^U)'
create-alias -g -e -d 'World-writable regular files' WX='*(.W)'

# Broken symlinks
create-alias -g -e -d 'Broken symbolic links recursively' BL='**/*(-@)'

# Files
create-alias -g -e -d 'Executable regular files' EX='*(*.)'
create-alias -g -e -d 'Non-hidden regular files' HF='*(.^D)'

# File extensions
create-alias -g -e -d 'Image files' IMG='*.(jpg|jpeg|png|gif|webp|avif|heic)'
create-alias -g -e -d 'Video files' VID='*.(mp4|mkv|mov|avi|webm)'
create-alias -g -e -d 'Audio files' AUD='*.(mp3|flac|ogg|m4a|wav)'
create-alias -g -e -d 'PDF files' PDF='*.pdf'
create-alias -g -e -d 'Log files' LOG='*.log'
create-alias -g -e -d 'Archive files' TAR='*.(tar|tar.gz|tgz|tar.xz|zip|7z)'
