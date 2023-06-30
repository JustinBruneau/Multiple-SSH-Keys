#!/bin/bash

# Demande à l'utilisateur le nom d'hôte ou l'adresse IP du serveur
read -p "Entrez le nom d'hôte ou l'adresse IP du serveur : " server

# Clés SSH disponibles
key_paths=("/root/.ssh/systeme_rsa" "/root/.ssh/progial_rsa" "/root/.ssh/id_rsa")

# Variable pour suivre la clé SSH utilisée
selected_key=""

# Boucle pour trouver la première clé qui ne nécessite pas de mot de passe
for key_path in "${key_paths[@]}"
do
    ssh -o PreferredAuthentications=publickey -i "$key_path" "$server" exit 2>/dev/null
    if [ $? -eq 0 ]; then
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
    read -s -p "Veuillez entrer votre mot de passe : 
" password
    sshpass -p "$password" ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no "$server"
fi