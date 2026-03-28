#!/usr/bin/env zsh

function src() {
  autoload -U compinit zrecompile
  rm "$ZCOMPDUMP"
  compinit -i -d "$ZCOMPDUMP"

  for f in "${ZDOTDIR:-~}/.zshrc" "$ZCOMPDUMP"; do
    zrecompile -p "$f" && command rm -f "$f".zwc.old
  done

  # Use $SHELL if it's available and a zsh shell
  local shell="$ZSH_ARGZERO"
  if [[ "${${SHELL:t}#-}" = zsh ]]; then
    shell="$SHELL"
  fi

  # Remove leading dash if login shell and run accordingly
  if [[ "${shell:0:1}" = "-" ]]; then
    exec -l "${shell#-}"
  else
    exec "$shell"
  fi
}

function zsh_time() {
  for _i in $(seq 1 10); do /usr/bin/time zsh -i -c exit; done
}

function generate_zsh_completions() {
  typeset -A commands=(
    [docker]="docker completion zsh"
    [ast-grep]="sg completions zsh"
    [bat]="bat --completion=zsh"
    [rustup]="rustup completions zsh"
    [cargo]="rustup completions zsh cargo"
    [chezmoi]="chezmoi completion zsh"
    [delta]="delta --generate-completion zsh"
    [eza]="curl -fsSL https://raw.githubusercontent.com/eza-community/eza/refs/heads/main/completions/zsh/_eza"
    [fd]="fd --gen-completions zsh"
    [gitleaks]="gitleaks completion zsh"
    [hk]="hk completion zsh"
    [mise]="mise completion zsh"
    [rg]="rg --generate complete-zsh"
    [tldr]="curl -fsSL https://raw.githubusercontent.com/tldr-pages/tlrc/refs/heads/main/completions/_tldr"
    [yq]="yq completion zsh"
    [gh]="gh completion --shell zsh"
    [dockerfmt]="dockerfmt completion zsh"
    [npm]="npm completion"
  )

  if [[ ! -d $ZCOMPDIR ]]; then mkdir -p $ZCOMPDIR; fi

  for k in "${(@k)commands}"; do
    local cmd="${commands[${k}]}"
    if builtin command -v $k >/dev/null 2>&1; then
      echo "Running '$cmd >| $ZCOMPDIR/_$k'"
      eval $cmd >|"$ZCOMPDIR/_$k"
    else
      echo "Command $k is not available"
    fi
  done
}
