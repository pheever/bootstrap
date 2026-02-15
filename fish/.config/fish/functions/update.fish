function update --description 'Update system and Homebrew packages'
    echo "=== apt ==="
    sudo apt-get update
    and sudo apt-get upgrade -y
    and sudo apt-get autoremove -y
    and sudo apt-get autoclean

    echo ""
    echo "=== brew ==="
    HOMEBREW_NO_ENV_HINTS=1 brew upgrade --casks
    and HOMEBREW_NO_ENV_HINTS=1 brew update --auto-update
    and HOMEBREW_NO_ENV_HINTS=1 brew upgrade
    and HOMEBREW_NO_ENV_HINTS=1 brew autoremove

    echo ""
    echo "=== npm ==="
    npm install -g --fund false npm@latest
end
