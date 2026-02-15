function docker-start --description 'Start Docker Engine'
    sudo systemctl start docker.socket docker.service
end
