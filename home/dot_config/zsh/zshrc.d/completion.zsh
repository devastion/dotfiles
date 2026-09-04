#!/usr/bin/env zsh

setopt always_to_end
setopt auto_list
setopt auto_param_keys
setopt auto_param_slash
setopt complete_in_word
setopt list_types

setopt no_list_beep

zmodload zsh/complist
zmodload -m -F zsh/files 'b:zf_*'

run-compinit() {
  emulate -L zsh

  local dumpfile="${ZSH_COMPDUMP_FILE:-$XDG_CACHE_HOME/zsh/zcompdump}"
  local dumpdir=${dumpfile:h}

  (($+functions[compinit])) || autoload -Uz compinit

  [[ -d $dumpdir ]] || zf_mkdir -p -- "$dumpdir" || return 1

  if [[ $1 == -f || $1 == --force ]]; then
    zf_rm -f -- "$dumpfile" "${dumpfile}.zwc"
  fi

  local -a args=('-i' '-d' "$dumpfile")

  if [[ -s $dumpfile && -n "${dumpfile}"(#qN.mh+24) ]]; then
    compinit -C "${args[@]}"
  else
    compinit "${args[@]}"
  fi

  if [[ -s $dumpfile &&
    (! -s ${dumpfile}.zwc || $dumpfile -nt ${dumpfile}.zwc) ]]; then
    {
      local lock=${dumpfile}.zwc.lock

      if zf_mkdir "$lock" 2> /dev/null; then
        zcompile -U -- "$dumpfile"
        zf_rmdir "$lock" 2> /dev/null
      fi
    } &|
  fi

  _comp_options+=(globdots)
}

typeset -x LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}

zstyle -e ':completion:*:default' list-colors 'reply=( "${(@s.:.)LS_COLORS}" )'
zstyle ':completion:*:default' list-prompt '%S%M matches%s'

zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path \
  "${ZSH_CACHE_HOME:-${XDG_CACHE_HOME:-$HOME/.cache}/zsh}/zcompcache"

zstyle ':completion:*' matcher-list \
  '' \
  '+m:{[:lower:]}={[:upper:]}' \
  '+m:{[:upper:]}={[:lower:]}' \
  '+m:{_-}={-_}' \
  'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

zstyle ':completion:*' menu no
zstyle ':completion:*:matches' group yes
zstyle ':completion:*:options' description yes
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format '%d (errors: %e)%b'
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format "No match: %d"
zstyle ':completion:*' format '%d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

zstyle ':completion:*' completer _complete _match

zstyle ':completion:*' list-dirs-first true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*:*:git:*' sort false

zstyle ':completion:*' complete-options true

zstyle ':completion:*:(rm|cp|mv|trash|vi|vim|nvim|kill|diff|__zoxide_z):*' ignore-line other
zstyle ':completion:*:(rm|cp|mv|trash|vi|vim|nvim|kill|diff|__zoxide_z):*' file-patterns '*:all-files'

zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'
zstyle ':completion:*:*:kill:*:processes' command \
  'ps -u ${USER:-$LOGNAME} -o pid,user,comm,%cpu,%mem'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:*' fzf-min-height 50
zstyle ':fzf-tab:*' switch-group '<' '>'

zstyle ':fzf-tab:complete:*:options' fzf-flags --preview-window=hidden
zstyle ':fzf-tab:complete:*:argument-1' fzf-flags --preview-window=hidden

zstyle ':fzf-tab:complete:(cd|z|nvim|vim):*' fzf-preview '$XDG_CONFIG_HOME/fzf/preview.sh ${(Q)realpath}'

zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git show --color=always $word'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
  'case "$group" in
    "commit tag") git show --color=always $word ;;
    *) git show --color=always $word | delta ;;
  esac'

zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
    "modified file") git diff $word | delta ;;
    "recent commit object name") git show --color=always $word | delta ;;
    *) git log --color=always $word ;;
  esac'
