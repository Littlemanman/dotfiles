# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# 瞬态显示
# 需要放在开头位置
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export HISTSIZE=50000
export SAVEHIST=10000
export HISTFILE=$HOME/.zsh_history

setopt EXTENDED_HISTORY       # 保存命令开始结束时间
setopt HIST_EXPIRE_DUPS_FIRST # 历史记录过大时首先删除重复项
setopt HIST_IGNORE_DUPS       # 忽视重复项
setopt HIST_IGNORE_SPACE      # 忽视从空格开始的命令
setopt HIST_VERIFY            # 历史扩展
setopt SHARE_HISTORY          # 共享历史纪录
setopt NO_HIST_BEEP           # 访问不存在的历史记录不发出警告声
setopt APPEND_HISTORY         # 追加到历史纪录文件

alias history="fc -li"
alias history-stat="history 0 | awk '{print \$2}' | sort | uniq -c | sort -n -r | head"

setopt AUTO_CD                  # 不用 cd 输入目录跳转
setopt AUTO_PUSHD               # cd 旧目录推送至目录栈
setopt PUSHD_IGNORE_DUPS        # 不存储重复项
setopt PUSHD_MINUS
setopt PUSHD_SILENT             # 不在 pushd 或 popd 后打印目录栈

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias -- -='cd -'
alias 1='cd -1'
alias 2='cd -2'
alias 3='cd -3'
alias 4='cd -4'
alias 5='cd -5'
alias 6='cd -6'
alias 7='cd -7'
alias 8='cd -8'
alias 9='cd -9'

alias md='mkdir -p'
alias rd=rmdir

alias l="ls --color -alih"
alias ls="ls --color "

function d () {
  if [[ -n $1 ]]; then
    dirs "$@"
  else
    dirs -v | head -n 10
  fi
}

if [[ -x "$(command -v zoxide)" ]]; then
   eval "$(zoxide init zsh --cmd j)"
fi

unsetopt MENU_COMPLETE   # 禁止自动选择第一个
unsetopt FLOW_CONTROL
setopt AUTO_MENU         # TAB按键自动选择下一个
setopt COMPLETE_IN_WORD # 补全开始时光标不动
setopt ALWAYS_TO_END    # 补全选择后光标跳至末尾
setopt AUTO_LIST           # Automatically list choices on ambiguous completion.
setopt AUTO_PARAM_SLASH    # If completed parameter is a directory, add a trailing slash.
setopt EXTENDED_GLOB       # Needed for file modification glob modifiers with compinit

function run-compinit {
  # Load and initialize the completion system ignoring insecure directories with a
  # cache time of 20 hours, so it should almost always regenerate the first time a
  # shell is opened each day.

  # References
  # https://github.com/sorin-ionescu/prezto/blob/master/modules/completion/init.zsh#L31-L44
  # https://github.com/sorin-ionescu/prezto/blob/master/runcoms/zlogin#L9-L15
  # http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Use-of-compinit
  # https://gist.github.com/ctechols/ca1035271ad134841284#gistcomment-2894219
  # https://htr3n.github.io/2018/07/faster-zsh/

  emulate -L zsh
  setopt local_options extended_glob

  autoload -Uz compinit
  if [[ -z "$ZSH_COMPDUMP" ]]; then
    ZSH_COMPDUMP=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump
  fi
  [[ -d "${ZSH_COMPDUMP:h}" ]] || mkdir -p "${ZSH_COMPDUMP:h}"

  # if compdump is less than 20 hours old, shortcut with `compinit -C`
  # glob magic explained:
  #   #q expands globs in conditional expressions
  #   N - sets null_glob option (no error on 0 results)
  #   mh-20 - modified less than 20 hours ago
  local comp_files=($ZSH_COMPDUMP(Nmh-20))
  if (( $#comp_files )); then
    compinit -i -C -d "$ZSH_COMPDUMP"
  else
    compinit -i -d "$ZSH_COMPDUMP"
    # keep zcompdump younger than cache time even if it isn't regenerated
    touch "$ZSH_COMPDUMP"
  fi

  # compile zcompdump, if modified, in background to increase startup speed
  {
    if [[ -s "$ZSH_COMPDUMP" && (! -s "${ZSH_COMPDUMP}.zwc" || "$ZSH_COMPDUMP" -nt "${ZSH_COMPDUMP}.zwc") ]]; then
      zcompile "$ZSH_COMPDUMP"
    fi
  } &!
}

zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:default' list-prompt '%S%M matches%s'

# Use caching to make completion for commands such as dpkg and apt usable.
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompcache"

# 是否敏感匹配
# CASE_SENSITIVE=true
if [[ "$CASE_SENSITIVE" = true ]]; then
  zstyle ':completion:*' matcher-list 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  setopt CASE_GLOB
else
  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
  unsetopt CASE_GLOB
fi
unset CASE_SENSITIVE

# Group matches and describe.
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format ' %F{purple} -- %d --%f'
zstyle ':completion:*:warnings' format ' %F{red}-- no matches found --%f'
zstyle ':completion:*' format ' %F{yellow}-- %d --%f'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Fuzzy match mistyped completions.
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# Increase the number of errors based on the length of the typed word. But make
# sure to cap (at 7) the max-errors to avoid hanging.
zstyle -e ':completion:*:approximate:*' max-errors 'reply=($((($#PREFIX+$#SUFFIX)/3>7?7:($#PREFIX+$#SUFFIX)/3))numeric)'

# Don't complete unavailable commands.
zstyle ':completion:*:functions' ignored-patterns '(_*|pre(cmd|exec))'

# Array completion element sorting.
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# Directories
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true

# History
zstyle ':completion:*:history-words' stop yes
zstyle ':completion:*:history-words' remove-all-dups yes
zstyle ':completion:*:history-words' list false
zstyle ':completion:*:history-words' menu yes

# Environment Variables
zstyle ':completion::*:(-command-|export):*' fake-parameters ${${${_comps[(I)-value-*]#*,}%%,*}:#-*-}


zstyle -e ':completion:*:hosts' hosts 'reply=(
  ${=${=${=${${(f)"$(cat {/etc/ssh/ssh_,~/.ssh/}known_hosts(|2)(N) 2> /dev/null)"}%%[#| ]*}//\]:[0-9]*/ }//,/ }//\[/ }
  ${=${(f)"$(cat /etc/hosts(|)(N) <<(ypcat hosts 2> /dev/null))"}%%(\#${_etc_host_ignores:+|${(j:|:)~_etc_host_ignores}})*}
  ${=${${${${(@M)${(f)"$(cat ~/.ssh/config 2> /dev/null)"}:#Host *}#Host }:#*\**}:#*\?*}}
)'

# Don't complete uninteresting users...
zstyle ':completion:*:*:*:users' ignored-patterns \
  adm amanda apache avahi beaglidx bin cacti canna clamav daemon \
  dbus distcache dovecot fax ftp games gdm gkrellmd gopher \
  hacluster haldaemon halt hsqldb ident junkbust ldap lp mail \
  mailman mailnull mldonkey mysql nagios \
  named netdump news nfsnobody nobody nscd ntp nut nx openvpn \
  operator pcap postfix postgres privoxy pulse pvm quagga radvd \
  rpc rpcuser rpm shutdown squid sshd sync uucp vcsa xfs '_*'

# ... unless we really want to.
zstyle '*' single-ignored show

# Ignore multiple entries.
zstyle ':completion:*:(rm|kill|diff):*' ignore-line other
zstyle ':completion:*:rm:*' file-patterns '*:all-files'

# Kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# Media Players
zstyle ':completion:*:*:mpg123:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
zstyle ':completion:*:*:mocp:*' file-patterns '*.(wav|WAV|mp3|MP3|ogg|OGG|flac):ogg\ files *(-/):directories'

# Mutt
if [[ -s "$HOME/.mutt/aliases" ]]; then
  zstyle ':completion:*:*:mutt:*' menu yes select
  zstyle ':completion:*:mutt:*' users ${${${(f)"$(<"$HOME/.mutt/aliases")"}#alias[[:space:]]}%%[[:space:]]*}
fi

# SSH/SCP/RSYNC
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'
#endregion

run-compinit

setopt NO_BEEP

function zsh-plugin-load() {
  local repo plugin_name plugin_dir initfile initfiles
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  for repo in $@; do
    plugin_name=${repo:t}
    plugin_dir=$ZPLUGINDIR/$plugin_name
    initfile=$plugin_dir/$plugin_name.plugin.zsh
    if [[ ! -d $plugin_dir ]]; then
      echo "Cloning $repo"
      git clone --depth 1 --recursive --shallow-submodules https://github.com/$repo $plugin_dir
    fi
    if [[ ! -e $initfile ]]; then
      initfiles=($plugin_dir/*.plugin.{z,}sh(N) $plugin_dir/*.{z,}sh{-theme,}(N))
      [[ ${#initfiles[@]} -gt 0 ]] || { echo >&2 "Plugin has no init file '$repo'." && continue }
      ln -sf "${initfiles[1]}" "$initfile"
    fi
    fpath+=$plugin_dir
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}

function zsh-plugin-update() {
  ZPLUGINDIR=${ZPLUGINDIR:-$HOME/.config/zsh/plugins}
  for d in $ZPLUGINDIR/*/.git(/); do
    echo "Updating ${d:h:t}..."
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}

function zsh-plugin-compile() {
  ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}
  autoload -U zrecompile
  local f
  for f in $ZPLUGINDIR/**/*.zsh{,-theme}(N); do
    zrecompile -pq "$f"
  done
}

function zsh-plugin-list() {
  echo $zsh_plugin_repos
}

zsh_plugin_repos=(
  zsh-users/zsh-history-substring-search
  zsh-users/zsh-autosuggestions
  romkatv/powerlevel10k
)

zsh-plugin-load $zsh_plugin_repos

# 接受建议按键
ZSH_AUTOSUGGEST_ACCEPT_WIDGETS=(
  end-of-line
  vi-forward-char
  vi-end-of-line
  vi-add-eol
)
# 接受部分建议按键
ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS=(
  forward-char
  forward-word
  emacs-forward-word
  vi-forward-word
  vi-forward-word-end
  vi-forward-blank-word
  vi-forward-blank-word-end
  vi-find-next-char
  vi-find-next-char-skip
)

export PROXY_ADDRESS="http://localhost:40003"

function setproxy() {
  export http_proxy=$PROXY_ADDRESS
  export https_proxy=$PROXY_ADDRESS
}

function unsetproxy() {
  unset http_proxy
  unset https_proxy
}

function gitsetproxy() {
  git config --global http.proxy $PROXY_ADDRESS
  git config --global https.proxy $PROXY_ADDRESS
}

function gitunsetproxy() {
  git config --global --unset http.proxy
  git config --global --unset https.proxy
}

function vterm_printf(){
  if [ -n "$TMUX" ] && ([ "${TERM%%-*}" = "tmux" ] || [ "${TERM%%-*}" = "screen" ] ); then
    # Tell tmux to pass the escape sequences through
    printf "\ePtmux;\e\e]%s\007\e\\" "$1"
  elif [ "${TERM%%-*}" = "screen" ]; then
    # GNU screen (screen, screen-256color, screen-256color-bce)
    printf "\eP\e]%s\007\e\\" "$1"
  else
    printf "\e]%s\e\\" "$1"
  fi
}
function vterm_prompt_end() {
  vterm_printf "51;A$(whoami)@$(cat /etc/hostname):$(pwd)";
}
setopt PROMPT_SUBST
PROMPT=$PROMPT'%{$(vterm_prompt_end)%}'

function vterm_cmd() {
  local vterm_elisp
  vterm_elisp=""
  while [ $# -gt 0 ]; do
    vterm_elisp="$vterm_elisp""$(printf '"%s" ' "$(printf "%s" "$1" | sed -e 's|\\|\\\\|g' -e 's|"|\\"|g')")"
    shift
  done
  vterm_printf "51;E$vterm_elisp"
}

export FZF_DEFAULT_COMMAND='fd --type f'

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

function pai() {
  pacman -Slq | fzf -q "$1" -m --preview-window hidden --bind 'alt-.:preview(pacman -Si {}),alt-n:preview-down,alt-p:preview-up' | xargs -ro sudo pacman -S
}

function par() {
  pacman -Qq | fzf -q "$1" -m --preview-window hidden --bind 'alt-.:preview(pacman -Qi {}),alt-n:preview-down,alt-p:preview-up' | xargs -ro sudo pacman -Rscn
}

bindkey -e
bindkey -M emacs '^[p' history-substring-search-up
bindkey -M emacs '^[n' history-substring-search-down

alias em="emacsclient -c "
alias emr="emacsclient -r "
alias suem="SUDO_EDITOR='emacsclient -c ' sudo -e"

if [ -e "/mnt/wsl" ];  then
  export PROXY_ADDRESS="http://$(ip route | awk '{print $3;exit}'):40003"
  export BROWSER="/mnt/c/Windows/explorer.exe "
  alias open="/mnt/c/Windows/explorer.exe "
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
