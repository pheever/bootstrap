eval (/home/linuxbrew/.linuxbrew/bin/brew shellenv fish)

fnm env --use-on-cd | source
set -gx GOPATH $HOME/source/go
fish_add_path $GOPATH/bin

if status is-interactive
    fzf --fish | source
    starship init fish | source
    source "$HOME/.cargo/env.fish"

    # Ctrl+Backspace: delete previous token
    bind ctrl-h backward-kill-word

    # Start SSH agent and load keys (prompts for passphrase once per boot)
    set -l keys
    for f in ~/.ssh/*_ed25519 ~/.ssh/*_ecdsa ~/.ssh/*_rsa ~/.ssh/*_dsa
        test -f "$f"; and set -a keys $f
    end
    if count $keys >/dev/null
        keychain --eval $keys | source
    end
end

function fish_greeting
    random choice "Persistence beats resistance. Keep typing." "Absence is information" "The void is not empty." "Today is a good day to outgrow yesterday." "Done is better than perfect. Just build." "Progress, not perfection." "Small progress > no progress. Keep going."
end

export GPG_TTY=$(tty) 