function update --description 'Update system and Homebrew packages'
    echo "=== apt ==="
    sudo apt-get update
    and sudo apt-get upgrade -y
    and sudo apt-get autoremove -y
    and sudo apt-get autoclean

    echo ""
    echo "=== brew ==="
    brew upgrade --casks
    and brew update --auto-update
    and brew upgrade
    and brew autoremove

    echo ""
    echo "=== npm ==="
    npm install -g npm@latest
end
