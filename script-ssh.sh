#!/bin/bash

# Demande à l'utilisateur le nom d'hôte ou l'adresse IP du serveur
read -p "Entrez le nom d'hôte ou l'adresse IP du serveur : " server

# Clés SSH disponibles
key_paths=("path_key1_rsa" "path_key2_rsa" "path_key3_rsa")

# Variable pour suivre la clé SSH utilisée
selected_key=""

# Fonction pour vérifier la connexion SSH avec une clé donnée
check_ssh_connection() {
    ssh -o PreferredAuthentications=publickey -i "$1" "$server" exit 2>/dev/null
    return $?
}

# Boucle pour trouver la première clé qui ne nécessite pas de mot de passe
for key_path in "${key_paths[@]}"
do
    if check_ssh_connection "$key_path"; then
        selected_key="$key_path"
        break
    fi
done

# Vérifie si une clé a été sélectionnée pour la connexion
if [ -n "$selected_key" ]; then
    echo "Connexion établie au serveur $server avec la clé $selected_key"
    ssh -i "$selected_key" "$server"
else
    echo "Échec de la connexion au serveur $server avec les clés SSH disponibles."
    read -s -p "Veuillez entrer votre mot de passe : " password
    sshpass -p "$password" ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no "$server"
fi
