#!/bin/bash

# ============================================================
#  _____   ___   _____  __  __        _   _  ___  ____   _____        _   _  ___  ____   _____  
# / ____| |_ _| | ____||  \/  |      | | | ||_ _||  _ \ / ___|      | \ | ||_ _||  _ \ / ___| 
# \___ \  | |  |  _|  | |\/| |______| |_| | | | | | | |\___ \ ______| |\| | | | | | | |\___ \ 
#  ___) | | |  | |___ | |  | |______|  _  | | | | |_| | ___) |______| |\  | | | | |_| | ___) |
# |____/ |___| |_____||_|  |_|      |_| |_||___||____/ |____/       |_| \_||___||____/ |____/ 
#
#                                 Créé par : Yassine Kabbaj
# ============================================================

# Couleurs
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}           VÉRIFICATION DES SERVICES DU SOC                 ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo ""

# Liste des services à vérifier
services=(
    # SIEM
    "elasticsearch"
    "kibana"
    "logstash"
    "filebeat"
    # NIDS
    "suricata"
    # HIDS
    "wazuh-manager"
    "wazuh-api"
)

# Vérification de chaque service
for service in "${services[@]}"; do
    status=$(systemctl is-active $service)
    
    # Déterminer la catégorie du service
    category=""
    if [[ "$service" == "elasticsearch" || "$service" == "kibana" || "$service" == "logstash" || "$service" == "filebeat" ]]; then
        category="SIEM"
    elif [[ "$service" == "suricata" ]]; then
        category="NIDS"
    elif [[ "$service" == "wazuh-manager" || "$service" == "wazuh-api" ]]; then
        category="HIDS"
    fi
    
    # Afficher le statut
    printf "%-15s %-25s : " "[$category]" "$service"
    
    if [ "$status" == "active" ]; then
        echo -e "${GREEN}[ACTIF]${NC}"
    else
        echo -e "${RED}[INACTIF - $status]${NC}"
        
        # Vérifier les journaux pour les services inactifs
        echo -e "  ${YELLOW}Dernières entrées du journal :${NC}"
        journalctl -u $service --no-pager -n 3 | sed 's/^/  /'
        echo ""
    fi
done

echo ""
echo -e "${BLUE}============================================================${NC}"

# Vérifier l'espace disque
echo -e "${YELLOW}Utilisation de l'espace disque :${NC}"
df -h / | awk 'NR==1 || /^\/dev/'

# Vérifier la mémoire
echo ""
echo -e "${YELLOW}Utilisation de la mémoire :${NC}"
free -h

echo ""
echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}           Vérification terminée                           ${NC}"
echo -e "${BLUE}============================================================${NC}"
