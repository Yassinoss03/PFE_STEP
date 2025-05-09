#!/bin/bash

# ============================================================
#  _____   ___   _____  __  __        _   _  ___  ____   _____        _   _  ___  ____   _____  
# / ____| |_ _| | ____||  \/  |      | | | ||_ _||  _ \ / ___|      | \ | ||_ _||  _ \ / ___| 
# \___ \  | |  |  _|  | |\/| |______| |_| | | | | | | |\___ \ ______| |\| | | | | | | |\___ \ 
#  ___) | | |  | |___ | |  | |______|  _  | | | | |_| | ___) |______| |\  | | | | |_| | ___) |
# |____/ |___| |_____||_|  |_|      |_| |_||___||____/ |____/       |_| \_||___||____/ |____/ 
#
#                                 Créé par : KHELLA Hamza
# ============================================================

# Script d'installation de l'agent Wazuh sur les endpoints
# Usage: ./install_wazuh_agent.sh <IP_SERVEUR_WAZUH>

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Vérifier si le script est exécuté en tant que root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}Ce script doit être exécuté en tant que root${NC}" 
   exit 1
fi

# Vérifier si l'adresse IP du serveur Wazuh est fournie
if [ -z "$1" ]; then
    echo -e "${RED}Erreur: Adresse IP du serveur Wazuh non spécifiée${NC}"
    echo -e "Usage: $0 <IP_SERVEUR_WAZUH>"
    exit 1
fi

# Variables
WAZUH_SERVER_IP="$1"
WAZUH_VERSION="4.3.0"
OS_TYPE=""
OS_VERSION=""

# Fonction pour afficher les messages
print_status() {
    echo -e "${BLUE}[*] ${NC}$1"
}

print_success() {
    echo -e "${GREEN}[+] ${NC}$1"
}

print_error() {
    echo -e "${RED}[-] ${NC}$1"
    exit 1
}

print_warning() {
    echo -e "${YELLOW}[!] ${NC}$1"
}

# Détection du système d'exploitation
detect_os() {
    print_status "Détection du système d'exploitation..."
    
    # Vérifier si c'est une distribution basée sur Debian
    if [ -f /etc/debian_version ]; then
        OS_TYPE="debian"
        if [ -f /etc/lsb-release ]; then
            . /etc/lsb-release
            OS_VERSION=$DISTRIB_CODENAME
        else
            OS_VERSION=$(cat /etc/debian_version)
        fi
        print_success "Système détecté: Debian/Ubuntu ($OS_VERSION)"
    
    # Vérifier si c'est une distribution basée sur RedHat
    elif [ -f /etc/redhat-release ]; then
        OS_TYPE="redhat"
        OS_VERSION=$(cat /etc/redhat-release)
        print_success "Système détecté: RedHat/CentOS ($OS_VERSION)"
    
    # Vérifier si c'est macOS
    elif [ "$(uname)" == "Darwin" ]; then
        OS_TYPE="darwin"
        OS_VERSION=$(sw_vers -productVersion)
        print_success "Système détecté: macOS ($OS_VERSION)"
    
    # Vérifier si c'est Windows avec WSL
    elif grep -qi microsoft /proc/version; then
        print_error "Windows avec WSL détecté. Ce script ne prend pas en charge l'installation de l'agent Wazuh sur WSL."
    
    # Système non pris en charge
    else
        print_error "Système d'exploitation non pris en charge. Ce script fonctionne avec Debian/Ubuntu, RedHat/CentOS et macOS."
    fi
}

# Installation de l'agent Wazuh sur Debian/Ubuntu
install_agent_debian() {
    print_status "Installation de l'agent Wazuh sur Debian/Ubuntu..."
    
    # Ajout du dépôt Wazuh
    apt-get update
    apt-get install -y curl apt-transport-https gnupg
    
    curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | apt-key add -
    echo "deb https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list
    apt-get update
    
    # Installation de l'agent Wazuh
    apt-get install -y wazuh-agent
    
    # Configuration de l'agent pour se connecter au serveur Wazuh
    sed -i "s/<address>127.0.0.1<\/address>/<address>$WAZUH_SERVER_IP<\/address>/" /var/ossec/etc/ossec.conf
    
    # Activer et démarrer l'agent
    systemctl daemon-reload
    systemctl enable wazuh-agent
    systemctl start wazuh-agent
    
    # Vérifier que l'agent fonctionne
    if systemctl is-active --quiet wazuh-agent; then
        print_success "Agent Wazuh installé et configuré avec succès"
    else
        print_error "Erreur lors de l'installation de l'agent Wazuh"
    fi
}

# Installation de l'agent Wazuh sur RedHat/CentOS
install_agent_redhat() {
    print_status "Installation de l'agent Wazuh sur RedHat/CentOS..."
    
    # Ajout du dépôt Wazuh
    rpm --import https://packages.wazuh.com/key/GPG-KEY-WAZUH
    cat > /etc/yum.repos.d/wazuh.repo << EOF
[wazuh]
gpgcheck=1
gpgkey=https://packages.wazuh.com/key/GPG-KEY-WAZUH
enabled=1
name=Wazuh repository
baseurl=https://packages.wazuh.com/4.x/yum/
protect=1
EOF
    
    # Installation de l'agent Wazuh
    yum -y install wazuh-agent
    
    # Configuration de l'agent pour se connecter au serveur Wazuh
    sed -i "s/<address>127.0.0.1<\/address>/<address>$WAZUH_SERVER_IP<\/address>/" /var/ossec/etc/ossec.conf
    
    # Activer et démarrer l'agent
    systemctl daemon-reload
    systemctl enable wazuh-agent
    systemctl start wazuh-agent
    
    # Vérifier que l'agent fonctionne
    if systemctl is-active --quiet wazuh-agent; then
        print_success "Agent Wazuh installé et configuré avec succès"
    else
        print_error "Erreur lors de l'installation de l'agent Wazuh"
    fi
}

# Installation de l'agent Wazuh sur macOS
install_agent_darwin() {
    print_status "Installation de l'agent Wazuh sur macOS..."
    
    # Téléchargement du package d'installation
    curl -o wazuh-agent.pkg https://packages.wazuh.com/4.x/macos/wazuh-agent-$WAZUH_VERSION-1.pkg
    
    # Installation du package
    installer -pkg wazuh-agent.pkg -target /
    
    # Configuration de l'agent pour se connecter au serveur Wazuh
    sed -i '' "s/<address>127.0.0.1<\/address>/<address>$WAZUH_SERVER_IP<\/address>/" /Library/Ossec/etc/ossec.conf
    
    # Démarrer l'agent
    /Library/Ossec/bin/wazuh-control start
    
    # Vérifier que l'agent fonctionne
    if pgrep -q wazuh-agent; then
        print_success "Agent Wazuh installé et configuré avec succès"
    else
        print_error "Erreur lors de l'installation de l'agent Wazuh"
    fi
}

# Programme principal
main() {
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${BLUE}      INSTALLATION DE L'AGENT WAZUH (HIDS) SUR ENDPOINT     ${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo ""
    echo -e "Serveur Wazuh: ${GREEN}$WAZUH_SERVER_IP${NC}"
    echo -e "Version Wazuh: ${GREEN}$WAZUH_VERSION${NC}"
    echo ""
    
    # Détecter le système d'exploitation
    detect_os
    
    # Installer l'agent en fonction du système d'exploitation
    case $OS_TYPE in
        debian)
            install_agent_debian
            ;;
        redhat)
            install_agent_redhat
            ;;
        darwin)
            install_agent_darwin
            ;;
        *)
            print_error "Type de système d'exploitation non pris en charge"
            ;;
    esac
    
    echo ""
    echo -e "${BLUE}============================================================${NC}"
    echo -e "${GREEN}Installation de l'agent Wazuh terminée!${NC}"
    echo -e "${BLUE}============================================================${NC}"
    echo ""
    echo -e "Pour vérifier l'état de l'agent:"
    
    if [ "$OS_TYPE" == "darwin" ]; then
        echo -e "  ${YELLOW}/Library/Ossec/bin/wazuh-control status${NC}"
    else
        echo -e "  ${YELLOW}systemctl status wazuh-agent${NC}"
    fi
    
    echo ""
    echo -e "Pour consulter les logs de l'agent:"
    
    if [ "$OS_TYPE" == "darwin" ]; then
        echo -e "  ${YELLOW}cat /Library/Ossec/logs/ossec.log${NC}"
    else
        echo -e "  ${YELLOW}tail -f /var/ossec/logs/ossec.log${NC}"
    fi
    
    echo ""
}

# Exécution du programme principal
main
