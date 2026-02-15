function docker-stop --description 'Stop Docker Engine'
    sudo systemctl stop docker.socket docker.service
end
