#!/bin/bash

# Récupérer le rôle de la machine
role=$(hostname)
destination_directory="./backup"


# Check if the flag file exists indicating the script has already been executed
if [ -f "$HOME/.script_backup_flag" ]; then
    echo "The script has already been executed. Exiting."
    exit 0
fi

function command_ssh {
    [ ${#} -gt 0 ] || { echo "Error: No arguments provided"; return 1; }
    sshpass -p root ssh -o StrictHostKeyChecking=no kidoly@$1 "$2"
    local status=$?
    if [ $status -ne 0 ]; then
        echo "Error: SSH command failed with status $status"
    fi
    return $status
}

# Create the flag file to indicate that the script is being executed
touch "$HOME/.script_backup_flag"

if [ ! -d "$destination_directory" ]; then
  echo "Le répertoire de destination n'existe pas. Création en cours..."
  mkdir -p "$destination_directory"
fi

# Nom du fichier d'archive (avec la date actuelle)
backup_filename="backup-$(date +'%Y-%m-%d').tar.gz"

# Vérification du succès de la sauvegarde
if [ $? -eq 0 ]; then
  echo "Sauvegarde terminée avec succès : $destination_directory/$backup_filename"
else
  echo "La sauvegarde a échoué."
fi

# Définir les éléments à sauvegarder en fonction du rôle
case $role in
  "database")
    # Sauvegarder la base de données
    echo "Sauvegarde de la base de données..."
    # Ajoutez ici la commande pour sauvegarder la base de données
    mysqldump -u username -p password database > "$destination_directory/database.sql"
    ;;
  "webserver")
    # Sauvegarder le site web
    echo "Sauvegarde du site web..."
    # Ajoutez ici la commande pour sauvegarder le site web
    cp -R /var/www/html "$destination_directory"
    ;;
  *)
    # Rôle non reconnu, afficher un message d'erreur
    echo "Erreur : rôle de machine non reconnu"
    exit 1
    ;;
esac

# Fin du script
echo "Sauvegarde terminée."
