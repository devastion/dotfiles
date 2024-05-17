export LANG="en_US.UTF-8"
export EDITOR="vi -e"
export VISUAL="nvim"
export WORDCHARS="*?[]~=&;&%^(){}<>"

# homebrew
export HOMEBREW_PREFIX="/opt/homebrew";
export HOMEBREW_CELLAR="/opt/homebrew/Cellar";
export HOMEBREW_REPOSITORY="/opt/homebrew";

# pnpm
export PNPM_HOME="${XDG_DATA_HOME}/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# dotfiles
export DOTFILES="${DOTFILES:-$HOME/.dotfiles}"

# tmux
export TMUX_PLUGINS_PATH="${TMUX_PLUGINS_PATH:-$HOME/.tmux/plugins}"

# ensure path arrays do not contain duplicates.
typeset -gU fpath path cdpath

path=(
  "/opt/homebrew/bin"
  "/opt/homebrew/sbin"
  "${HOME}/.cargo/bin"
  "${HOME}/.local/bin"
  "${HOME}/.orbstack/bin"
  "${HOME}/.local/share/fnm"
  $path
)

cdpath=(
  "${HOME}/Projects"
  "${HOME}/Projects/github"
  "${HOME}/Projects/gitlab"
  $cdpath
)

fpath=(
  $(brew --prefix)/share/zsh/site-functions
  "${ZDOTDIR}/completions"
  "/Applications/OrbStack.app/Contents/Resources/completions/zsh"
  $fpath
)

bindkey -e
