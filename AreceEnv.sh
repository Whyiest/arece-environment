#!/bin/bash

# Définition du temps d'affichage des informations : 
SHOW_INFO_DELAY=5

# Stockage du nom d'utilisateur dans une variable
USERNAME=$(whoami)

# Default Path
MAC_FOLDER_PATH='./MacLauncher'
WINDOWS_FOLDER_PATH='./WindowsLauncher'
HOST_VOLUME_PATH="/home/$USERNAME/ros2_ws"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Pas de couleur

# Affichage de "ARECE" en art ASCII
echo -e "${BLUE} "
echo -e "    █████╗ ██████╗ ███████╗ ██████╗ ███████╗"
echo -e "   ██╔══██╗██╔══██╗██╔════╝██╔═══   ██╔════╝"
echo -e "   ███████║██████╔╝███████╗██║      ███████╗"
echo -e "   ██╔══██║██╔══██╗██║     ██║      ██║     "
echo -e "   ██║  ██║██║  ██║███████║╚██████╔╝███████║"
echo -e "   ╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚══════╝"
echo -e "${NC}"
echo ""

# Information programme
echo -e "${GREEN}Si vous avez déjà lancé et créé une instance Docker avec cet outil, supprimez-la avec docker kill [instance] et effacez les fichiers liés."
echo ""

# Affichage du nom d'utilisateur
echo -e "${BLUE} Utilisateur actuel : ${NC} $USERNAME"

# Demande à l'utilisateur de choisir entre Mac et Windows
echo -e "${BLUE} Choisissez votre système d'exploitation (${NC}mac/windows${BLUE}) : ${NC}"
read OS_CHOICE

# Formation du path 

LAUNCHER_PATH=""

if [ "$OS_CHOICE" = "mac" ]; then
    LAUNCHER_PATH="$MAC_FOLDER_PATH"
elif [ "$OS_CHOICE" = "windows" ]; then
    LAUNCHER_PATH="$WINDOWS_FOLDER_PATH"

else
    echo -e "${NC}[${RED}⨯${NC}] Erreur : choix invalide, votre os n'est pas pris en charge. Veuillez choisir 'mac' ou 'windows'. ${NC}"
    echo ""
    exit 1
fi

DOCKER_COMPOSE_FILE="$LAUNCHER_PATH/docker-compose.yml"
DOCKER_FILE="$LAUNCHER_PATH/Dockerfile"

# Information utilisateur - Début de test -----------------
echo ""
echo -e "${NC}[${GREEN}⧁${NC}] ${BLUE}Démarrage vérification..."
echo ""

# Remplacement du nom d'utilisateur dans le fichier docker-compose.yml
sed -i "s#/home/CHANGEHERE/ros2_ws#/home/$USERNAME/ros2_ws#g" "$DOCKER_COMPOSE_FILE"

echo -e "${NC}[${GREEN}✔${NC}] ${BLUE}User : $USERNAME"

# Vérification de l'existence du fichier docker-compose.yml
if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "${NC}[${RED}⨯${NC}] Erreur : le fichier $DOCKER_COMPOSE_FILE n'existe pas.${NC}"
    echo ""
    exit 1
fi

echo -e "${NC}[${GREEN}✔${NC}] ${BLUE}Docker Compose path :${NC} $DOCKER_COMPOSE_FILE"

# Vérification de l'existence du fichier Dockerfile
if [ ! -f "$DOCKER_FILE" ]; then
    echo -e "${NC}[${RED}⨯${NC}] Erreur : le fichier $DOCKER_FILE n'existe pas.${NC}"
    echo ""
    exit 1
fi
echo -e "${NC}[${GREEN}✔${NC}] ${BLUE}Docker File path :${NC} $DOCKER_FILE"


# Vérification de l'existence du volume sur l'host
if [ ! -d "$HOST_VOLUME_PATH" ]; then
    echo -e "${NC}[${RED}⨯${NC}] Erreur : le dossier $HOST_VOLUME_PATH doit être créé sur l'host pour poursuivre.${NC}"
    echo ""
    exit 1
fi
echo -e "${NC}[${GREEN}✔${NC}] ${BLUE}Host volume path :${NC} $HOST_VOLUME_PATH"


# Détecter la présence d'une carte graphique NVIDIA ou AMD
nvidia_card=$(lspci | grep -i nvidia)
amd_card=$(lspci | grep -i 'amd\|radeon')
intel_card=$(lspci | grep -i 'intel')

# Afficher le résultat
if [ ! -z "$nvidia_card" ]; then
    echo -e "${NC}[${GREEN}✔${NC}] ${BLUE}Carte graphique détectée : ${NC}NVIDIA"
elif [ ! -z "$amd_card" ]; then
    echo -e "${NC}[${GREEN}✔${NC}] ${BLUE}Carte graphique détectée : ${NC}AMD"
elif [ ! -z "$intel_card" ]; then
    echo -e "${NC}[${GREEN}✔${NC}] ${BLUE}Carte graphique détectée : ${NC}INTEL"
else
    echo "${NC}[${RED}⨯${NC}] Carte graphique non supportée. Actuellement supporté : NVIDIA, AMD et INTEL."
    exit 1
fi

# Information utilisateur - Fin de test ---------------------
echo ""
echo -e "${NC}[${GREEN}✔${NC}] ${BLUE}Vérification terminée."
echo ""
echo -e "${NC}[${YELLOW}⧁${NC}] ${GREEN}Prêt au lancement, début dans ${NC}$SHOW_INFO_DELAY second(s)."
echo ""
sleep $SHOW_INFO_DELAY



# Lancement du container avec docker-compose
echo -e "${NC}[${BLUE}⧁${NC}] ${BLUE}Construction du container Docker... ${NC}"
cd "$LAUNCHER_PATH"
docker-compose build || { echo -e "${NC}[${RED}⨯${NC}] Erreur lors de la construction du container Docker.${NC}"; exit 1; }

# Lancement du container avec docker-compose
echo ""
echo -e "${NC}[${BLUE}⧁${NC}] ${BLUE}Lancement du container Docker... ${NC}"
docker-compose up -d || { echo -e "${NC}[${RED}⨯${NC}] Erreur lors du démarrage du container Docker.${NC}"; exit 1; }

# Fin programme
echo ""
echo -e "${NC}[${GREEN}✔${NC}] ${BLUE}Container Docker lancé avec succès ! ${NC}"
