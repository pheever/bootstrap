eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv)

if status is-interactive
    # Commands to run in interactive sessions can go here
    fzf --fish | source
    starship init fish | source
    source "$HOME/.cargo/env.fish"

    # SSH agent via keychain (prompts for passphrase once per boot)
    if type -q keychain
        keychain --eval --quiet github_ed25519 | source
    end
end

function fish_greeting
    random choice "Persistence beats resistance. Keep typing." "Absence is information" "The void is not empty." "Today is a good day to outgrow yesterday." "Done is better than perfect. Just build." "Progress, not perfection." "Small progress > no progress. Keep going."
end

export GPG_TTY=$(tty)