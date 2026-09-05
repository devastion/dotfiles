#!/usr/bin/env zsh

fzf:edit() {
  emulate -L zsh
  local -a files
  files=("${(@f)$(fzf:find "$@")}") || return 1
  files=(${(@)files:#})
  (($#files)) || return 1
  "${EDITOR:-nvim}" -- "${files[@]}"
}

fzf:alias() {
  emulate -L zsh
  local sel kind name tab=$'\t'
  sel=$(
  {
    print -rl -- "${(@k)aliases/#/alias${tab}}"
    print -rl -- "${(@k)functions/#/func${tab}}"
  } | fzf --delimiter=$'\t' --with-nth=2 \
    --preview 'case {1} in
                  alias) alias -- {2};;
                  func)  whence -f -- {2} | head -80;;
                esac' \
    --preview-window=right:60%:wrap \
    --header='enter print definition'
) || return 1
  kind=${sel%%$'\t'*}
  name=${sel#*$'\t'}
  case $kind in
    alias)
      alias -- "$name"
      ;;
    func)
      whence -f -- "$name"
      ;;
  esac
}

fzf:cd() {
  emulate -L zsh
  local dir
  dir="$(
    fd --type d --hidden --follow --exclude .git |
      fzf --query="${*:-}" \
        --preview 'eza --tree --level=2 --color=always --icons=auto {} | head -200' \
        --preview-window 'right:60%,nohidden'
  )" || return 1
  [[ -n $dir ]] && builtin cd -- "$dir"
}

fzf:env() {
  emulate -L zsh
  local entry
  entry="$(
    env |
      fzf --preview 'printf %s {2..}' \
        --preview-window=right:60%:wrap \
        --delimiter='=' \
        --bind "ctrl-y:execute-silent(printf %s {2..} | pbcopy)+abort" \
        --header 'ctrl-y copy value · enter print value'
  )" || return 1
  [[ -z $entry ]] && return 1
  print -r -- "${entry#*=}"
}

fzf:find() {
  emulate -L zsh
  local -a selected
  selected=("${(@f)$(
    fd --type f --hidden --follow --exclude .git |
    	fzf --query="${*:-}" \
    		--preview 'bat --style=numbers --color=always --line-range :500 {}' \
    		--preview-window=right:60%:wrap
  )}") || return 1
  selected=(${(@)selected:#})
  (($#selected)) || return 1
  print -r -- ${(F)selected}
}

fzf:history() {
  emulate -L zsh
  local print_only=0 cmd
  [[ $1 == -p ]] && {
    print_only=1
    shift
  }

  cmd="$(
    fc -lnr 1 |
      fzf --query="${*:-}" --no-sort \
        --header='enter copy · fhist -p prints'
  )" || return 1
  [[ -z $cmd ]] && return 1

  if ((print_only)); then
    print -r -- "$cmd"
  else
    print -rn -- "$cmd" | pbcopy
    print -r -- "Copied: $cmd"
  fi
}

fzf:kill() {
  emulate -L zsh
  local -a pids
  pids=("${(@f)$(
    ps -ef |
    	sed 1d |
    	fzf --multi --header='TAB multi-select · enter terminate' \
    		--preview 'echo {}' --preview-window=down:3:wrap |
    	awk '{print $2}'
  )}") || return 1
  pids=(${(@)pids:#})
  (($#pids)) || return 1
  kill -- $pids
}

fzf:log() {
  emulate -L zsh
  local logfile
  logfile="$(fd --type f --extension log --hidden . "$HOME" /var/log 2> /dev/null | fzf \
    --preview 'tail -n 100 {}' \
    --header "Press Enter to tail file")"

  [[ -n $logfile ]] && tail -f "$logfile"
}

fzf:man() {
  emulate -L zsh
  local page
  page="$(
    man -k "${@:-.}" 2> /dev/null |
      fzf --query="${*:-}" \
        --preview 'man $(echo {1} | sed "s/(.*//") 2>/dev/null | col -bx | head -120' \
        --preview-window=right:60%
  )" || return 1
  [[ -z $page ]] && return 1
  man -- "${${(z)page}[1]%%\(*}"
}

fzf:path() {
  emulate -L zsh
  local dir
  dir="$(
    print -rl -- $path |
      fzf --preview 'eza --tree --level=1 --color=always --icons=auto {} 2>/dev/null || ls -la {}' \
        --header='PATH entry'
  )" || return 1
  [[ -n $dir ]] && builtin cd -- "$dir"
}

fzf:port() {
  emulate -L zsh
  local selection pid
  if [[ $OSTYPE == darwin* ]]; then
    selection="$(
      lsof -nP -iTCP -sTCP:LISTEN 2> /dev/null |
        fzf --header='enter kill selected listener' \
          --preview 'echo {}' --preview-window=down:2:wrap
    )" || return 1
    pid="${${(z)selection}[2]}"
  else
    selection="$(
      ss -lptn 2> /dev/null |
        fzf --header='enter kill selected listener'
    )" || return 1
    [[ $selection == *pid=* ]] || return 1
    pid=${${selection##*pid=}%%[^0-9]*}
  fi
  [[ $pid == <-> ]] || return 1
  kill -- "$pid" && print -r -- "Terminated $pid"
}

fzf:rg() {
  emulate -L zsh
  local reload='reload:rg --column --line-number --no-heading --color=always --smart-case {q} || :'
  local selection file line
  selection=$(
    fzf --disabled --ansi \
      --query="${*:-}" \
      --bind "start:$reload" --bind "change:$reload" \
      --delimiter : \
      --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' \
      --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
      --bind 'ctrl-o:execute:${EDITOR:-nvim} {1} +{2}'
  ) || return 1
  [[ -z $selection ]] && return 1

  file=${selection%%:*}
  line=${${selection#*:}%%:*}
  ${EDITOR:-nvim} "+${line}" -- "$file"
}

fzf:git-alias() {
  emulate -L zsh
  git config --get-regexp '^alias\.' |
    sed 's/^alias\.//' |
    awk '{ print length($1), $1, substr($0, index($0,$2)) }' |
    sort -n -k1,1 -k2,2 |
    awk '{ printf "%s\t%s\t%s\n", $1, $2, substr($0, index($0,$3)) }' |
    fzf \
      --ansi \
      --delimiter=$'\t' \
      --with-nth=2 \
      --preview 'echo -e "git {2}\n{3}"' \
      --preview-window 'right:60%,nohidden,wrap' \
      --bind 'enter:become(git {2})'
}

fzf:git-browse() {
  emulate -L zsh
  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
      --bind "ctrl-m:execute:
(grep -o '[a-f0-9]\{7\}' | head -1 |
xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
{}
FZF-EOF"
}

fzf:git-checkout() {
  emulate -L zsh
  git rev-parse --is-inside-work-tree > /dev/null 2>&1 || {
    print -u2 'Not a git repository'
    return 1
  }

  local branch
  branch=$(
    git for-each-ref --sort=-committerdate \
      --format='%(refname:short)' refs/heads/ refs/remotes/ |
      grep -vE 'HEAD$' |
      fzf --preview 'git log --oneline --graph --color=always -n 30 -- {}' \
        --preview-window 'right:60%,nohidden'
  ) || return 1
  [[ -z $branch ]] && return 1

  if [[ $branch == remotes/*/* ]]; then
    git checkout --track "${branch#remotes/}" 2> /dev/null ||
      git checkout "${branch##*/}"
  else
    git checkout "$branch"
  fi
}

fzf:git-log() {
  emulate -L zsh
  git rev-parse --is-inside-work-tree > /dev/null 2>&1 || {
    print -u2 'Not a git repository'
    return 1
  }

  git log --graph --color=always \
    --format='%C(auto)%h%d %s %C(black)%C(bold)%cr' "$@" |
    fzf --ansi --no-sort --reverse --tiebreak=index \
      --preview 'git show --color=always --stat -p {1}' \
      --preview-window 'right:60%,nohidden' \
      --bind "ctrl-y:execute-silent(printf %s {1} | pbcopy)+abort" \
      --bind 'enter:execute:git show --color=always {1} | less -R'
}

fzf:git-stash() {
  emulate -L zsh
  local out query reflog_selector sha
  local -a selection
  while out=$(git stash list "$@" |
    fzf --ansi --no-sort --reverse --print-query --query="$query" \
      --expect=ctrl-a,ctrl-b,ctrl-p,del \
      --bind="ctrl-u:preview-page-up" \
      --bind="ctrl-d:preview-page-down" \
      --bind="ctrl-k:preview-up" \
      --bind="ctrl-j:preview-down" \
      --header='<C-a> stash apply <C-b> stash branch co <C-p> stash pop <Del> stash drop' \
      --preview="echo {} | cut -d':' -f1 | xargs git stash show -p" \
      --preview-window 'down:85%,nohidden'); do
    selection=("${(f)out}")

    query="${selection[1]}"

    reflog_selector=$(echo "${selection[3]}" | cut -d ':' -f 1)

    case "${selection[2]}" in
      ctrl-a)
        git stash apply "$reflog_selector"
        break
        ;;
      ctrl-b)
        sha=$(echo "${selection[3]}" | grep -o '[a-f0-9]\{7\}')
        git stash branch "stash-$sha" "$reflog_selector"
        break
        ;;
      ctrl-p)
        git stash pop "$reflog_selector"
        break
        ;;
      del)
        git stash drop "$reflog_selector"
        ;;
    esac
  done
}

fzf:git-status() {
  emulate -L zsh
  git rev-parse --is-inside-work-tree > /dev/null 2>&1 || {
    print -u2 'Not a git repository'
    return 1
  }

  local -a paths
  paths=("${(@f)$(
    git status --short | awk '{print ($3 == "->") ? $4 : $2}' | fzf --multi \
    	--header='TAB multi-select · enter stage · ctrl-o open in editor' \
    	--preview 'git diff --cached -- {} | delta --width $FZF_PREVIEW_COLUMNS && git diff -- {} |
    		delta --width $FZF_PREVIEW_COLUMNS && git diff --no-index -- /dev/null {} | delta --width $FZF_PREVIEW_COLUMNS' \
    	--preview-window 'nohidden' \
    	--bind "ctrl-o:execute(${EDITOR:-nvim} {})"
  )}") || return 1
  paths=(${(@)paths:#})
  (($#paths)) || return 1

  git add -- $paths
}
