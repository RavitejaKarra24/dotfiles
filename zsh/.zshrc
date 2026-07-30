# keychain id_rsa --agents ssh  # moved before instant prompt

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off
typeset -U path PATH

# Keep package metadata fresh when running `brew upgrade`. Homebrew separately
# caches repository updates for 24 hours and formula/cask API data for 450
# seconds, which can hide newly published packages until a manual update.
unset HOMEBREW_AUTO_UPDATE_CHECKED HOMEBREW_AUTO_UPDATE_COMMAND
unset HOMEBREW_AUTO_UPDATING HOMEBREW_COMMAND_DEPTH HOMEBREW_API_UPDATED
unset HOMEBREW_BREW_FILE HOMEBREW_PATH
export HOMEBREW_AUTO_UPDATE_SECS=0
export HOMEBREW_API_AUTO_UPDATE_SECS=0

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
#ZSH_THEME="robbyrussell"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.

plugins=(git zsh-autosuggestions zsh-syntax-highlighting web-search)

[[ -d "$HOME/.grok/completions/zsh" ]] && fpath=("$HOME/.grok/completions/zsh" $fpath)
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.config/zsh/theme.zsh ]] || source ~/.config/zsh/theme.zsh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[[ -d /usr/local/opt/adoptopenjdk11/bin ]] && path=(/usr/local/opt/adoptopenjdk11/bin $path)
# eval "$(gh copilot alias -- zsh)"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"
[[ -d "$HOME/go/bin" ]] && path=($path "$HOME/go/bin")

# ---- NVM (lazy-loaded on first use) ----
export NVM_DIR="$HOME/.nvm"
_load_nvm() {
  unset -f _load_nvm nvm node npm npx
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
}
nvm()  { _load_nvm; nvm "$@"; }
node() { _load_nvm; node "$@"; }
npm()  { _load_nvm; npm "$@"; }
npx()  { _load_nvm; npx "$@"; }

# ---- FZF (single source; OMZ already loads zsh-syntax-highlighting) ----
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# history setup (Atuin is primary; keep a modest native backup)
HISTFILE=$HOME/.zhistory
SAVEHIST=5000
HISTSIZE=5000
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_ignore_space
setopt hist_verify

bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# ---- Eza / Zoxide ----
if command -v eza >/dev/null 2>&1; then
  alias ls="eza --icons=always"
fi
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd="z"
fi

# ---- Secrets (API keys, tokens - not tracked by git) ----
[[ -f ~/.zshrc.secrets ]] && source ~/.zshrc.secrets

function cursor() {
    if [[ $# = 0 ]]; then
        open -a "Cursor"
    elif [[ -n "${commands[cursor]:-}" ]]; then
        "${commands[cursor]}" "$@"
    else
        local arg arg_path
        local -a paths
        for arg in "$@"; do
            [[ "$arg" = /* ]] && arg_path="$arg" || arg_path="$PWD/${arg#./}"
            paths+=("$arg_path")
        done
        open -a "Cursor" "${paths[@]}"
    fi
}

# Anaconda only if present (avoid hard PATH noise on machines without it)
[[ -d /opt/homebrew/anaconda3/bin ]] && export PATH="/opt/homebrew/anaconda3/bin:$PATH"

export PATH="/usr/local/opt/openjdk/bin:$PATH"

# --- Editor / Yazi ---
export EDITOR="nvim"
export VISUAL="nvim"

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	{
		yazi "$@" --cwd-file="$tmp"
		if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
			builtin cd -- "$cwd"
		fi
	} always {
		rm -f -- "$tmp"
	}
}

# Daily driver aliases
alias n="nvim"
alias lg="lazygit"
alias bt="btop"
gq() {
  local selected
  selected="$(ghq list -p | fzf)" || return
  [[ -n "$selected" ]] || return
  builtin cd -- "$selected"
}

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/Downloads/google-cloud-sdk/path.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/path.zsh.inc"; fi

# The next line enables shell command completion for gcloud.
if [ -f "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc" ]; then . "$HOME/Downloads/google-cloud-sdk/completion.zsh.inc"; fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

#alias
alias k="kubectl"

# Mac setup for pomo
alias work="timer 60m && terminal-notifier -message 'Pomodoro'\
        -title 'Work Timer is up! Take a Break'\
        -appIcon \"$HOME/Pictures/pumpkin.png\"\
        -sound Crystal"
        
alias rest="timer 10m && terminal-notifier -message 'Pomodoro'\
        -title 'Break is over! Get back to work'\
        -appIcon \"$HOME/Pictures/pumpkin.png\"\
        -sound Crystal"

[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"


if command -v rbenv >/dev/null 2>&1; then
  eval "$(rbenv init - zsh)"
fi

# Added by Antigravity
[[ -d "$HOME/.antigravity/antigravity/bin" ]] && path=("$HOME/.antigravity/antigravity/bin" $path)

#dictionary
dict() {
    local word=$1
    if [[ -z "$word" ]]; then
        echo "Usage: dict <word>"
        return 1
    fi

    echo "Searching for: $word"
    echo "------------------------------------------"

    # 1. Try Native macOS Offline Dictionary
    local offline_result
    offline_result=$(python3 - "$word" <<'PY' 2>/dev/null
try:
    from DictionaryServices import DCSCopyTextDefinition
    import sys
    word = sys.argv[1]
    result = DCSCopyTextDefinition(None, word, (0, len(word)))
    if result:
        print(result.strip())
        sys.exit(0)
    sys.exit(1)
except Exception:
    sys.exit(1)
PY
)

    if [[ -n "$offline_result" ]]; then
        echo -e "\033[1;32m[OFFLINE]\033[0m"
        echo "$offline_result"
    else
        # 2. Try Modern Online API (fallback)
        echo -e "\033[1;34m[ONLINE]\033[0m"
        
        # Using the Free Dictionary API + jq for clean formatting
        # If you don't have 'jq' installed, run: brew install jq
        local encoded_word
        encoded_word=$(python3 -c 'import sys, urllib.parse; print(urllib.parse.quote(sys.argv[1], safe=""))' "$word") || return
        local api_url="https://api.dictionaryapi.dev/api/v2/entries/en/$encoded_word"
        local response
        if ! response=$(curl --fail --silent --show-error --max-time 10 "$api_url"); then
            echo "Online lookup failed."
            return 1
        fi

        if [[ "$response" == *"title\":\"No Definitions Found"* ]]; then
             echo "Word not found. (Check your spelling: '$word'?)"
        else
            # Extracting just the definitions using python for formatting
            echo "$response" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    for entry in data:
        print(f'{entry.get(\"word\", \"\").upper()}')
        for meaning in entry.get(\"meanings\", []):
            part = meaning.get(\"partOfSpeech\", \"\")
            print(f'\n[{part}]')
            for definition in meaning.get(\"definitions\", []):
                print(f' - {definition.get(\"definition\", \"\")}')
except:
    print('Error parsing dictionary data.')
"
        fi
    fi
    echo "------------------------------------------"
}


# # Play fahh sound on command error
# _fahh_on_error() {
#   local exit_code=$?
#   if [[ $exit_code -ne 0 ]]; then
#     (afplay ~/fahhhhh.mp3 &>/dev/null &)   # macOS
#     # (mpg123 ~/fahhhhh.mp3 &>/dev/null &) # Linux with mpg123
#     # (ffplay -nodisp -autoexit ~/fahhhhh.mp3 &>/dev/null &) # Linux with ffplay
#   fi
# }
#
# precmd_functions+=(_fahh_on_error)

[[ -d "$HOME/.local/share/solana/install/active_release/bin" ]] && path=("$HOME/.local/share/solana/install/active_release/bin" $path)

# Added by LM Studio CLI (lms)
[[ -d "$HOME/.lmstudio/bin" ]] && path=($path "$HOME/.lmstudio/bin")
# End of LM Studio CLI section

alias rust-book='open -a "Zen Browser" ~/dock/raviteja/rust/book/book/index.html'

# Added by Antigravity IDE
[[ -d "$HOME/.antigravity-ide/antigravity-ide/bin" ]] && path=("$HOME/.antigravity-ide/antigravity-ide/bin" $path)

# >>> grok installer >>>
[[ -d "$HOME/.grok/bin" ]] && path=("$HOME/.grok/bin" $path)
# <<< grok installer <<<
# Global npm bin if available (avoid slow `npm bin -g` every shell)
[[ -d "$HOME/.npm-global/bin" ]] && path=("$HOME/.npm-global/bin" $path)
[[ -d /opt/homebrew/bin ]] && path=(/opt/homebrew/bin $path)

# Added by Antigravity CLI installer
[[ -d "$HOME/.local/bin" ]] && path=("$HOME/.local/bin" $path)
[ -s "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
