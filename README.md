# PFE_STEP
SOC Setup - Security Operations Center Deployment
 _____   ___   _____  __  __        _   _  ___  ____   _____        _   _  ___  ____   _____  
/ ____| |_ _| | ____||  \/  |      | | | ||_ _||  _ \ / ___|      | \ | ||_ _||  _ \ / ___| 
\___ \  | |  |  _|  | |\/| |______| |_| | | | | | | |\___ \ ______| |\| | | | | | | |\___ \ 
 ___) | | |  | |___ | |  | |______|  _  | | | | |_| | ___) |______| |\  | | | | |_| | ___) |
|____/ |___| |_____||_|  |_|      |_| |_||___||____/ |____/       |_| \_||___||____/ |____/
À propos
Ce projet fournit un script d'installation automatisée pour déployer un Centre d'Opérations de Sécurité (SOC) complet, intégrant plusieurs composants de sécurité essentiels :

SIEM (Security Information and Event Management) :

Elasticsearch
Kibana
Logstash
Filebeat


NIDS (Network Intrusion Detection System) :

Suricata


HIDS (Host Intrusion Detection System) :

Wazuh



Prérequis

Système d'exploitation Ubuntu 18.04/20.04/22.04 LTS
Droits d'administrateur (root)
Au moins 4 Go de RAM
Au moins 10 Go d'espace disque
Connexion Internet stable

Installation rapide
bash# Cloner le repository
git clone https://github.com/your-username/soc_setup.git

# Accéder au répertoire du projet
cd soc_setup

# Rendre le script exécutable
chmod +x soc_setup.sh

# Exécuter le script d'installation
sudo ./soc_setup.sh
Composants
1. SIEM (Security Information and Event Management)
Le SIEM constitue le cœur de notre SOC, assurant la collecte, l'analyse et la visualisation des données de sécurité.

Elasticsearch : Moteur de recherche et d'analyse pour stocker les données de sécurité
Kibana : Interface de visualisation pour explorer et analyser les données
Logstash : Agrégation et transformation des logs provenant de diverses sources
Filebeat : Agent léger pour la collecte des logs système et leur envoi vers le SIEM

2. NIDS (Network Intrusion Detection System)
Le NIDS surveille le trafic réseau pour détecter les activités malveillantes.

Suricata : Système de détection d'intrusion réseau hautes performances

3. HIDS (Host Intrusion Detection System)
Le HIDS surveille les systèmes hôtes pour détecter les modifications suspectes ou les comportements anormaux.

Wazuh : Solution complète de détection d'intrusion basée sur l'hôte

Accès aux interfaces
Une fois l'installation terminée, vous pouvez accéder aux interfaces web:

Kibana: http://votre-ip:5601
Elasticsearch: http://votre-ip:9200
API Wazuh: http://votre-ip:55000

Installation de l'agent Wazuh sur les endpoints
Pour installer l'agent Wazuh sur les machines à surveiller:
bash# Copier le script d'installation de l'agent
scp scripts/install_wazuh_agent.sh user@endpoint:/tmp/

# Se connecter à l'endpoint et exécuter le script
ssh user@endpoint "sudo bash /tmp/install_wazuh_agent.sh IP_DU_SERVEUR_SOC"
Maintenance
Pour vérifier l'état des services :
bashsudo ./scripts/check_services.sh
Dépannage
En cas de problème, consultez les journaux des services :
bash# Elasticsearch
sudo journalctl -u elasticsearch

# Kibana
sudo journalctl -u kibana

# Logstash
sudo journalctl -u logstash

# Suricata
sudo journalctl -u suricata

# Wazuh
sudo journalctl -u wazuh-manager
Contributeurs

Kabbaj Yassine - Créateur du projet

Licence
Ce projet est sous licence MIT - voir le fichier LICENSE pour plus de détails.
