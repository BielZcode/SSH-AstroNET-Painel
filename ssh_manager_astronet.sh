#!/bin/bash

# Arquivo onde os detalhes dos servidores SSH e usuários serão armazenados
SSH_CONFIG_FILE="ssh_servers.txt"
USERS_FILE="ssh_users.txt"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Função para adicionar um novo servidor SSH
add_server() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "      Adicionar Servidor      "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome do servidor:"
    read server_name
    echo "Digite o endereço IP ou hostname do servidor:"
    read server_ip
    echo "Digite o nome de usuário para o servidor:"
    read server_user
    echo "$server_name,$server_ip,$server_user" >> $SSH_CONFIG_FILE
    echo -e "${GREEN}Servidor adicionado com sucesso!${NC}"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para remover um servidor SSH
remove_server() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "      Remover Servidor        "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome do servidor a ser removido:"
    read server_name
    grep -v "^$server_name," $SSH_CONFIG_FILE > temp && mv temp $SSH_CONFIG_FILE
    echo -e "${GREEN}Servidor removido com sucesso!${NC}"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para listar todos os servidores SSH
list_servers() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "       Servidores SSH         "
    echo -e "==============================${NC}"
    echo
    if [ ! -s $SSH_CONFIG_FILE ]; then
        echo -e "${RED}Nenhum servidor cadastrado.${NC}"
    else
        cat $SSH_CONFIG_FILE | while IFS=, read -r name ip user; do
            echo -e "${YELLOW}Nome:${NC} $name, ${YELLOW}IP/Hostname:${NC} $ip, ${YELLOW}Usuário:${NC} $user"
        done
    fi
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para se conectar a um servidor SSH
connect_server() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "     Conectar ao Servidor     "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome do servidor ao qual deseja se conectar:"
    read server_name
    server_info=$(grep "^$server_name," $SSH_CONFIG_FILE)
    if [ -z "$server_info" ]; then
        echo -e "${RED}Servidor não encontrado!${NC}"
        echo
        read -p "Pressione Enter para continuar..."
        return
    fi
    server_ip=$(echo $server_info | cut -d',' -f2)
    server_user=$(echo $server_info | cut -d',' -f3)
    ssh $server_user@$server_ip
}

# Função para criar um cliente de teste
create_test_user() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "     Criar Cliente Teste      "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome de usuário:"
    read username
    password=$(openssl rand -base64 12)
    expiry_date=$(date -d "+1 day" +"%Y-%m-%d")
    echo "$username:$password:$expiry_date" >> $USERS_FILE
    echo -e "${GREEN}Usuário de teste criado com sucesso!${NC}"
    echo -e "${YELLOW}Usuário:${NC} $username"
    echo -e "${YELLOW}Senha:${NC} $password"
    echo -e "${YELLOW}Expira em:${NC} $expiry_date"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para criar um novo usuário
create_user() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "        Criar Usuário         "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome de usuário:"
    read username
    echo "Digite a senha:"
    read -s password
    echo "Digite a duração (em dias):"
    read duration
    expiry_date=$(date -d "+$duration days" +"%Y-%m-%d")
    echo "$username:$password:$expiry_date" >> $USERS_FILE
    echo -e "${GREEN}Usuário criado com sucesso!${NC}"
    echo -e "${YELLOW}Usuário:${NC} $username"
    echo -e "${YELLOW}Senha:${NC} $password"
    echo -e "${YELLOW}Expira em:${NC} $expiry_date"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para remover um usuário
remove_user() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "       Remover Usuário        "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome de usuário a ser removido:"
    read username
    grep -v "^$username:" $USERS_FILE > temp && mv temp $USERS_FILE
    echo -e "${GREEN}Usuário removido com sucesso!${NC}"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para renovar um usuário
renew_user() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "       Renovar Usuário        "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome de usuário a ser renovado:"
    read username
    echo "Digite a duração adicional (em dias):"
    read additional_days
    user_info=$(grep "^$username:" $USERS_FILE)
    if [ -z "$user_info" ]; then
        echo -e "${RED}Usuário não encontrado!${NC}"
        echo
        read -p "Pressione Enter para continuar..."
        return
    fi
    old_expiry_date=$(echo $user_info | cut -d':' -f3)
    new_expiry_date=$(date -d "$old_expiry_date + $additional_days days" +"%Y-%m-%d")
    sed -i "s/$username:.*:$old_expiry_date/$username:$(echo $user_info | cut -d':' -f2):$new_expiry_date/" $USERS_FILE
    echo -e "${GREEN}Usuário renovado com sucesso!${NC}"
    echo -e "${YELLOW}Nova data de expiração:${NC} $new_expiry_date"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para listar usuários online
list_online_users() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "       Usuários Online        "
    echo -e "==============================${NC}"
    echo
    who | grep -E "pts|tty"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para exibir o menu
show_menu() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "   Menu de Gerenciamento SSH  "
    echo -e "==============================${NC}"
    echo
    echo "1. Adicionar servidor SSH"
    echo "2. Remover servidor SSH"
    echo "3. Listar servidores SSH"
    echo "4. Conectar a um servidor SSH"
    echo "5. Criar cliente de teste"
    echo "6. Criar usuário"
    echo "7. Remover usuário"
    echo "8. Renovar usuário"
    echo "9. Listar usuários online"
    echo "10. Sair"
    echo
}

# Função principal
main() {
    while true; do
        show_menu
        echo "Escolha uma opção:"
        read choice
        case $choice in
            1) add_server ;;
            2) remove_server ;;
            3) list_servers ;;
            4) connect_server ;;
            5) create_test_user ;;
            6) create_user ;;
            7) remove_user ;;
            8) renew_user ;;
            9) list_online_users ;;
            10) exit 0 ;;
            *) echo -e "${RED}Opção inválida!${NC}" ;;
        esac
    done
}

# Criar os arquivos de configuração se eles não existirem
if [ ! -f $SSH_CONFIG_FILE ]; then
    touch $SSH_CONFIG_FILE
fi

if [ ! -f $USERS_FILE ]; then
    touch $USERS_FILE
fi

# Executar a função principal
main
#!/bin/bash

# Arquivo onde os detalhes dos servidores SSH e usuários serão armazenados
SSH_CONFIG_FILE="ssh_servers.txt"
USERS_FILE="ssh_users.txt"

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sem cor

# Função para adicionar um novo servidor SSH
add_server() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "      Adicionar Servidor      "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome do servidor:"
    read server_name
    echo "Digite o endereço IP ou hostname do servidor:"
    read server_ip
    echo "Digite o nome de usuário para o servidor:"
    read server_user
    echo "$server_name,$server_ip,$server_user" >> $SSH_CONFIG_FILE
    echo -e "${GREEN}Servidor adicionado com sucesso!${NC}"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para remover um servidor SSH
remove_server() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "      Remover Servidor        "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome do servidor a ser removido:"
    read server_name
    grep -v "^$server_name," $SSH_CONFIG_FILE > temp && mv temp $SSH_CONFIG_FILE
    echo -e "${GREEN}Servidor removido com sucesso!${NC}"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para listar todos os servidores SSH
list_servers() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "       Servidores SSH         "
    echo -e "==============================${NC}"
    echo
    if [ ! -s $SSH_CONFIG_FILE ]; then
        echo -e "${RED}Nenhum servidor cadastrado.${NC}"
    else
        cat $SSH_CONFIG_FILE | while IFS=, read -r name ip user; do
            echo -e "${YELLOW}Nome:${NC} $name, ${YELLOW}IP/Hostname:${NC} $ip, ${YELLOW}Usuário:${NC} $user"
        done
    fi
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para se conectar a um servidor SSH
connect_server() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "     Conectar ao Servidor     "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome do servidor ao qual deseja se conectar:"
    read server_name
    server_info=$(grep "^$server_name," $SSH_CONFIG_FILE)
    if [ -z "$server_info" ]; then
        echo -e "${RED}Servidor não encontrado!${NC}"
        echo
        read -p "Pressione Enter para continuar..."
        return
    fi
    server_ip=$(echo $server_info | cut -d',' -f2)
    server_user=$(echo $server_info | cut -d',' -f3)
    ssh $server_user@$server_ip
}

# Função para criar um cliente de teste
create_test_user() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "     Criar Cliente Teste      "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome de usuário:"
    read username
    password=$(openssl rand -base64 12)
    expiry_date=$(date -d "+1 day" +"%Y-%m-%d")
    echo "$username:$password:$expiry_date" >> $USERS_FILE
    echo -e "${GREEN}Usuário de teste criado com sucesso!${NC}"
    echo -e "${YELLOW}Usuário:${NC} $username"
    echo -e "${YELLOW}Senha:${NC} $password"
    echo -e "${YELLOW}Expira em:${NC} $expiry_date"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para criar um novo usuário
create_user() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "        Criar Usuário         "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome de usuário:"
    read username
    echo "Digite a senha:"
    read -s password
    echo "Digite a duração (em dias):"
    read duration
    expiry_date=$(date -d "+$duration days" +"%Y-%m-%d")
    echo "$username:$password:$expiry_date" >> $USERS_FILE
    echo -e "${GREEN}Usuário criado com sucesso!${NC}"
    echo -e "${YELLOW}Usuário:${NC} $username"
    echo -e "${YELLOW}Senha:${NC} $password"
    echo -e "${YELLOW}Expira em:${NC} $expiry_date"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para remover um usuário
remove_user() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "       Remover Usuário        "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome de usuário a ser removido:"
    read username
    grep -v "^$username:" $USERS_FILE > temp && mv temp $USERS_FILE
    echo -e "${GREEN}Usuário removido com sucesso!${NC}"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para renovar um usuário
renew_user() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "       Renovar Usuário        "
    echo -e "==============================${NC}"
    echo
    echo "Digite o nome de usuário a ser renovado:"
    read username
    echo "Digite a duração adicional (em dias):"
    read additional_days
    user_info=$(grep "^$username:" $USERS_FILE)
    if [ -z "$user_info" ]; then
        echo -e "${RED}Usuário não encontrado!${NC}"
        echo
        read -p "Pressione Enter para continuar..."
        return
    fi
    old_expiry_date=$(echo $user_info | cut -d':' -f3)
    new_expiry_date=$(date -d "$old_expiry_date + $additional_days days" +"%Y-%m-%d")
    sed -i "s/$username:.*:$old_expiry_date/$username:$(echo $user_info | cut -d':' -f2):$new_expiry_date/" $USERS_FILE
    echo -e "${GREEN}Usuário renovado com sucesso!${NC}"
    echo -e "${YELLOW}Nova data de expiração:${NC} $new_expiry_date"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para listar usuários online
list_online_users() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "       Usuários Online        "
    echo -e "==============================${NC}"
    echo
    who | grep -E "pts|tty"
    echo
    read -p "Pressione Enter para continuar..."
}

# Função para exibir o menu
show_menu() {
    clear
    echo -e "${BLUE}=============================="
    echo -e "   Menu de Gerenciamento SSH  "
    echo -e "==============================${NC}"
    echo
    echo "1. Adicionar servidor SSH"
    echo "2. Remover servidor SSH"
    echo "3. Listar servidores SSH"
    echo "4. Conectar a um servidor SSH"
    echo "5. Criar cliente de teste"
    echo "6. Criar usuário"
    echo "7. Remover usuário"
    echo "8. Renovar usuário"
    echo "9. Listar usuários online"
    echo "10. Sair"
    echo
}

# Função principal
main() {
    while true; do
        show_menu
        echo "Escolha uma opção:"
        read choice
        case $choice in
            1) add_server ;;
            2) remove_server ;;
            3) list_servers ;;
            4) connect_server ;;
            5) create_test_user ;;
            6) create_user ;;
            7) remove_user ;;
            8) renew_user ;;
            9) list_online_users ;;
            10) exit 0 ;;
            *) echo -e "${RED}Opção inválida!${NC}" ;;
        esac
    done
}

# Criar os arquivos de configuração se eles não existirem
if [ ! -f $SSH_CONFIG_FILE ]; then
    touch $SSH_CONFIG_FILE
fi

if [ ! -f $USERS_FILE ]; then
    touch $USERS_FILE
fi

# Executar a função principal
main
