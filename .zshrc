# ===========================================
# === Install zsh if it is not installed. ===
# ===========================================
export ZSH="$HOME/.oh-my-zsh"
if [ ! -d $ZSH ]; then
  echo "oh-my-zsh is not installed. Installing it..."
  sh -c "$(curl -fsSL https://install.ohmyz.sh/)"
fi
plugins=(git aws)
source $ZSH/oh-my-zsh.sh


# ================================
# === Export paths and aliases ===
# ================================

export VISUAL=lvim
export EDITOR=lvim

alias vim="lvim"
alias lg="lazygit"
alias config="git --git-dir=$HOME/.cfg/ --work-tree=$HOME"
alias lconfig="lazygit --git-dir=$HOME/.cfg/ --work-tree=$HOME"

export GOPATH=$HOME/go
export GOROOT=/opt/homebrew/opt/go/libexec

export PNPM_HOME=$HOME/Library/pnpm

case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

export PATH=/opt/homebrew/bin:$PATH
export PATH=$HOME/github/flutter/bin:$PATH
export PATH=$HOME/bin:$PATH
export PATH=$HOME/.local/bin:$PATH
export PATH=$HOME/.pub-cache/bin:$PATH
export PATH=$GOPATH/bin:$PATH
export PATH=$GOROOT/bin:$PATH


# =============================
# === powerlevel 10k config ===
# =============================

if [ ! -d $ZSH/custom/themes/powerlevel10k ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH/custom/themes/powerlevel10k
fi
source $ZSH/custom/themes/powerlevel10k/powerlevel10k.zsh-theme
source ~/.p10k.zsh

eval "$(zoxide init zsh)"


# =============================
# === vi mode configuration ===
# =============================

export ZVM_VI_ESCAPE_BINDKEY=jk
export ZVM_VI_HIGHLIGHT_FOREGROUND=white
export ZVM_VI_HIGHLIGHT_BACKGROUND=blue

if [ ! -d $ZSH/custom/plugins/zsh-vi-mode ]; then
  git clone --depth=1 https://github.com/jeffreytse/zsh-vi-mode $ZSH/custom/plugins/zsh-vi-mode
fi
source $ZSH/custom/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh


# NOTE: Wrap this source inside the `function zvm_after_init() {}` because otherwise CTRL-r is not associated to fzf
function zvm_after_init() {
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
}

# NOTE: Workaround for the weird copy-pasting stuff based on https://github.com/jeffreytse/zsh-vi-mode/issues/19
my_zvm_vi_yank() {
  zvm_vi_yank
  echo -en "${CUTBUFFER}" | cbread
}

my_zvm_vi_delete() {
  zvm_vi_delete
  echo -en "${CUTBUFFER}" | cbread
}

my_zvm_vi_change() {
  zvm_vi_change
  echo -en "${CUTBUFFER}" | cbread
}

my_zvm_vi_change_eol() {
  zvm_vi_change_eol
  echo -en "${CUTBUFFER}" | cbread
}

my_zvm_vi_substitute() {
  zvm_vi_substitute
  echo -en "${CUTBUFFER}" | cbread
}

my_zvm_vi_substitute_whole_line() {
  zvm_vi_substitute_whole_line
  echo -en "${CUTBUFFER}" | cbread
}

my_zvm_vi_put_after() {
  CUTBUFFER=$(cbprint)
  zvm_vi_put_after
  zvm_highlight clear # NOTE: zvm_vi_put_after introduces weird highlighting for me
}

my_zvm_vi_put_before() {
  CUTBUFFER=$(cbprint)
  zvm_vi_put_before
  zvm_highlight clear # NOTE: zvm_vi_put_before introduces weird highlighting for me
}

my_zvm_vi_replace_selection() {
    CUTBUFFER=$(pbpaste)
    zvm_vi_replace_selection
    echo -en "${CUTBUFFER}" | cbread
}

# NOTE(gmusat): this is introduced by me, based on the original zvm_vi_change_eol.
#  It does the same thing but without changing mode.
function zvm_vi_delete_eol() {
  local bpos=$CURSOR epos=$CURSOR

  # Find the end of current line
  for ((; $epos<$#BUFFER; epos++)); do
    if [[ "${BUFFER:$epos:1}" == $'\n' ]]; then
      break
    fi
  done

  CUTBUFFER=${BUFFER:$bpos:$((epos-bpos))}
  BUFFER="${BUFFER:0:$bpos}${BUFFER:$epos}"

  zvm_reset_repeat_commands $ZVM_MODE c 0 $#CUTBUFFER
  # zvm_select_vi_mode $ZVM_MODE_INSERT
}

# NOTE(gmusat): This is made completely by me, not based
# on anything specially.
function my_zvm_delete_char() {
  CUTBUFFER=${BUFFER:$CURSOR:1}

  BUFFER="${BUFFER:0:$CURSOR}${cutbuf}${BUFFER:$CURSOR+1}"
  echo -en "${CUTBUFFER}" | cbread
}

my_zvm_vi_delete_eol() {
  zvm_vi_delete_eol
  echo -en "${CUTBUFFER}" | cbread
}

zvm_after_lazy_keybindings() {
  zvm_define_widget my_zvm_vi_yank
  zvm_define_widget my_zvm_vi_delete
  zvm_define_widget my_zvm_vi_delete_after
  zvm_define_widget my_zvm_vi_change
  zvm_define_widget my_zvm_vi_change_eol
  zvm_define_widget my_zvm_vi_put_after
  zvm_define_widget my_zvm_vi_put_before
  zvm_define_widget my_zvm_vi_delete_eol
  zvm_define_widget my_zvm_vi_substitute
  zvm_define_widget my_zvm_vi_substitute_whole_line
  zvm_define_widget my_zvm_vi_replace_selection
  zvm_define_widget my_zvm_delete_char

  zvm_bindkey vicmd 'C' my_zvm_vi_change_eol
  zvm_bindkey vicmd 'P' my_zvm_vi_put_before
  zvm_bindkey vicmd 'D' my_zvm_vi_delete_eol
  zvm_bindkey vicmd 'S' my_zvm_vi_substitute_whole_line
  zvm_bindkey vicmd 'p' my_zvm_vi_put_after
  zvm_bindkey vicmd 'x' my_zvm_delete_char

  zvm_bindkey visual 'p' my_zvm_vi_replace_selection
  zvm_bindkey visual 'v' undefined-key
  zvm_bindkey visual 'y' my_zvm_vi_yank
  zvm_bindkey visual 'd' my_zvm_vi_delete
  zvm_bindkey visual 'x' my_zvm_vi_delete
  zvm_bindkey visual 'c' my_zvm_vi_change
}

if [[ $(uname) = "Darwin" ]]; then
  on_mac_os=0
else
  on_mac_os=1
fi

cbread() {
  if [[ $on_mac_os -eq 0 ]]; then
    pbcopy
  else
    xclip -selection primary -i -f | xclip -selection secondary -i -f | xclip -selection clipboard -i
  fi
}

cbprint() {
  if [[ $on_mac_os -eq 0 ]]; then
    pbpaste
  else
    if   x=$(xclip -o -selection clipboard 2> /dev/null); then
      echo -n $x
    elif x=$(xclip -o -selection primary   2> /dev/null); then
      echo -n $x
    elif x=$(xclip -o -selection secondary 2> /dev/null); then
      echo -n $x
    fi
  fi
}
