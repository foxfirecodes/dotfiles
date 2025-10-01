fpath+=(~/.config/zsh/comp ~/.zfunc)

# enable autocomplete (adapted from https://gist.github.com/ctechols/ca1035271ad134841284)
autoload -Uz compinit
if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
  compinit
else
  compinit -C
fi

# we want history yes plz
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# zmv is cool
autoload -Uz zmv

function _zsh_chpwd_ls {
  ls -F
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _zsh_chpwd_ls


# Use viins keymap
bindkey -v

bindkey '^q' push-line

# Enable Ctrl-x-e to edit command line.
# autoload -Uz edit-command-line
# zle -N edit-command-line
# bindkey '^xe' edit-command-line
# bindkey '^x^e' edit-command-line

# Enable ZSH reverse-search with ^R.
bindkey '^R' history-incremental-search-backward

# reclaim ^s (source: https://superuser.com/a/385290)
stty stop undef
stty start undef

# source: https://github.com/sorin-ionescu/prezto/issues/28
# Insert "sudo " at the beginning of the line
function _zsh_prepend_sudo {
  if [[ $BUFFER != "sudo "* ]]; then
    BUFFER="sudo $BUFFER"; CURSOR+=5
  fi
}
zle -N _zsh_prepend_sudo
bindkey '^s' _zsh_prepend_sudo

# and then my own addition
function _zsh_un_prepend_sudo {
  if [[ $BUFFER = "sudo "* ]]; then
      (( CURSOR -= 5 ))
      BUFFER="${BUFFER[6,-1]}"
  fi
}

zle -N _zsh_un_prepend_sudo
bindkey '^[s' _zsh_un_prepend_sudo

function _zsh_copy_buffer {
    # my custom alias will be used on linux
    echo -n "$BUFFER" | pbcopy
}

zle -N _zsh_copy_buffer
bindkey '^[c' _zsh_copy_buffer

if [ -z "$TMUX" ]; then
    # if not running in tmux, bind C-a to attach
    function _zsh_tmux_attach {
        BUFFER=" tmux at"
        zle accept-line
    }
    zle -N _zsh_tmux_attach
    bindkey '^a' _zsh_tmux_attach

    function _zsh_tmux_new_pwd {
        local session_name="$(basename "$(pwd)")"
        BUFFER=" tmux at -t '$session_name' 2>/dev/null || tmux new-session -s '$session_name'"
        zle accept-line
    }
    zle -N _zsh_tmux_new_pwd
    bindkey '^o' _zsh_tmux_new_pwd
fi

if command -v lazygit >/dev/null; then
    function _zsh_lazygit {
        BUFFER=" lazygit"
        zle accept-line
    }
    zle -N _zsh_lazygit
    bindkey '^g' _zsh_lazygit
fi

### zsh plugins ###

export ZSH_CUSTOM="$HOME/.config/zsh"

# zsh-autosuggestions
source "$ZSH_CUSTOM/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh"
bindkey '^ ' autosuggest-accept
export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=7'

# fast-syntax-highlighting
source "$ZSH_CUSTOM/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh"
# fix for freezing when highlighting ssh commands
FAST_HIGHLIGHT[chroma-ssh]=""

# history-search-multi-word
source "$ZSH_CUSTOM/plugins/history-search-multi-word/history-search-multi-word.plugin.zsh"
zstyle :plugin:history-search-multi-word reset-prompt-protect 3
