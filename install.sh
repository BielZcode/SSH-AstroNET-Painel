#!/bin/bash

# Função para exibir mensagens coloridas
echo_color() {
    local color_code=$1
    local message=$2
    echo -e "${color_code}${message}\033[0m"
}

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Arquivos de configuração
SSH_CONFIG_FILE="ssh_servers.txt"
USERS_FILE="ssh_users.txt"

# Verificar e instalar pacotes necessários
install_packages() {
    echo_color $BLUE "Atualizando a lista de pacotes..."
    sudo apt update

    packages=("openssh-client" "openssl")

    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q $package; then
            echo_color $YELLOW "Instalando $package..."
            sudo apt install -y $package
        else
            echo_color $GREEN "$package já está instalado."
        fi
    done

    echo_color $GREEN "Todos os pacotes necessários estão instalados."
}

# Função para criar arquivos de configuração
create_config_files() {
    if [ ! -f $SSH_CONFIG_FILE ]; then
        touch $SSH_CONFIG_FILE
        echo_color $GREEN "Arquivo de configuração $SSH_CONFIG_FILE criado."
    else
        echo_color $YELLOW "Arquivo de configuração $SSH_CONFIG_FILE já existe."
    fi

    if [ ! -f $USERS_FILE ]; then
        touch $USERS_FILE
        echo_color $GREEN "Arquivo de configuração $USERS_FILE criado."
    else
        echo_color $YELLOW "Arquivo de configuração $USERS_FILE já existe."
    fi
}

# Executar a função de instalação de pacotes
install_packages

# Executar a função de criação de arquivos de configuração
create_config_files
