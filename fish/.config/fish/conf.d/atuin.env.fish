
if command -q atuin
    atuin init fish | source
else if test -r "$HOME/.atuin/bin/env.fish"
    source "$HOME/.atuin/bin/env.fish"
end
