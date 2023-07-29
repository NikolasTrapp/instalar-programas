#!/bin/sh

#VARIAVEIS

log_file='instalar-programas.log'
linha='-=-=-=-=--=-=-=-=--=-=-=-=--=-=-=-=--=-=-=-=--=-=-=-=--=-=-=-=-'

#DECLARANDO FUNCOES
imprimir_e_jogar_pro_log () {
    echo $1 >> $log_file
    echo $1
    echo $linha >> $log_file
}

verificar_programa_instalado() {
    if command -v "$1" > /dev/null; then
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - O PROGRAMA $1 JA ESTA INSTALADO"
        return 1
    fi
    if [ -x "$(command -v pacman)" ]; then
        if pacman -Qs "$1" >/dev/null; then
            imprimir_e_jogar_pro_log "[ $(date +"%T") ] - O PROGRAMA $1 JA ESTA INSTALADO"
            return 1
        else
            return 0
        fi
    elif [ -x "$(command -v pamac)" ]; then
        if pamac list -i | grep -q "^$1 "; then
            imprimir_e_jogar_pro_log "[ $(date +"%T") ] - O PROGRAMA $1 JA ESTA INSTALADO"
            return 1
        else
            return 0
        fi
    elif [ -x "$(command -v dpkg)" ]; then
        if dpkg -l "$1" | grep -q '^ii'; then
            imprimir_e_jogar_pro_log "[ $(date +"%T") ] - O PROGRAMA $1 JA ESTA INSTALADO"
            return 1
        else
            return 0
        fi
    else
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - GERENCIADOR DE PACOTES NAO SUPORTADO. NAO FOI POSSIVEL VERIFICAR O PROGRAMA $1"
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - ENCERRANDO O PROGRAMA!"
        exit 1
    fi

    
    if command -v "$1" >/dev/null; then
        return 0
    else
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - O PROGRAMA $1 JA ESTA INSTALADO"
        return 1
    fi
}

atualizar_sistema() {
    imprimir_e_jogar_pro_log "[ $(date +"%T") ] - ATUALIZANDO SISTEMA... "
    sudo pacman -Syu

    if [ $? -eq 0 ]; then
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - SISTEMA ATUALIZADO COM SUCESSO!"
    else
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - OCORREU UM ERRO DURANTE A ATUALIZACAO DO SISTEMA"
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - DESEJA CONTINUAR ASSIM MESMO (S/N)?"
        read resposta
        if [ "$resposta" = "N" ] || [ "$resposta" = "n" ]; then
            imprimir_e_jogar_pro_log "[ $(date +"%T") ] - ENCERRANDO O SCRIPT..."
            exit 1
        fi
    fi
}

instalar_programa_pacman() {
    verificar_programa_instalado "$1"
    if [ $? -eq 1 ]; then
        return 1
    fi

    max_tentativas=2
    tentativas=0

    imprimir_e_jogar_pro_log "[ $(date +"%T") ] - INSTALANDO O PROGRAMA $1"

    while [ $tentativas -lt $max_tentativas ]; do
        sudo pacman -S --noconfirm $1
    if [ $? -eq 0 ]; then
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - INSTALACAO DO $1 CONCLUIDA COM SUCESSO!"
        return
    else
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - OCORREU UM ERRO DURANTE A INSTALACAO DO $1, TENTANTO MAIS 1 VEZ!"
        tentativas=$((tentativas+1))
    fi
    done
}

instalar_programa_pamac() {
    verificar_programa_instalado "$1"
    if [ $? -eq 1 ]; then
        return 1
    fi

    max_tentativas=2
    tentativas=0

    imprimir_e_jogar_pro_log "[ $(date +"%T") ] - INSTALANDO O PROGRAMA $1"

    while [ $tentativas -lt $max_tentativas ]; do
        sudo pamac install --no-confirm $1
    if [ $? -eq 0 ]; then
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - INSTALACAO DO $1 CONCLUIDA COM SUCESSO!"
        return
    else
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - OCORREU UM ERRO DURANTE A INSTALACAO DO $1, TENTANTO MAIS 1 VEZ!"
        tentativas=$((tentativas+1))
    fi
    done
}

#INICIANDO ARQUIVO DE LOG
touch ${log_file}

imprimir_e_jogar_pro_log "[ $(date +"%T") ] - INICIANDO INSTALACAO DE PROGRAMAS... "

# atualizar_sistema

# LISTA DE PROGRAMAS A SEREM INSTALADOS COM PACMAN
programas_pacman=(
    'curl'
    'code'
    'jre11-openjdk-headless' 
    'jre11-openjdk' 
    'jdk11-openjdk' 
    'openjdk11-src'
    'vim'
    'maven'
    'postgresql'
    'dbeaver'
    'bitwarden'
    'discord'
    'docker'
)

imprimir_e_jogar_pro_log "[ $(date +"%T") ] - INICIANDO INSTALACAO DE PROGRAMAS ATRAVES DO PACMAN"
for programa in "${programas_pacman[@]}"; do
    instalar_programa_pacman "$programa"
done

# LISTA DE PROGRAMAS A SEREM INSTALADOS COM PAMAC
programas_pamac=(
    'gparted'
    'intellij-idea-ultimate-edition'
    'spotify'
)

imprimir_e_jogar_pro_log "[ $(date +"%T") ] - INICIANDO INSTALACAO DE PROGRAMAS ATRAVES DO PAMAC"
for programa in "${programas_pamac[@]}"; do
    instalar_programa_pamac "$programa"
done


#INSTALACAO DE PROGRAMAS MANUALMENTE

#INSTALACAO DO RUST
verificar_programa_instalado rust
if [ $? -eq 0 ]; then
    imprimir_e_jogar_pro_log "[ $(date +"%T") ] - INSTALANDO O PROGRAMA rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    verificar_programa_instalado rust
    if [ $? -eq 1 ]; then
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - INSTALACAO DO rust CONCLUIDA COM SUCESSO!"
    else
        imprimir_e_jogar_pro_log "[ $(date +"%T") ] - OCORREU UM ERRO DURANTE A INSTALACAO DO rust!"
    fi
fi