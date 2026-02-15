if command -q keychain
    set -l keys
    for f in ~/.ssh/*_ed25519 ~/.ssh/*_ecdsa ~/.ssh/*_rsa ~/.ssh/*_dsa
        test -f "$f"; and set -a keys $f
    end
    if count $keys >/dev/null
        keychain --eval --quiet $keys | source
    end
end
