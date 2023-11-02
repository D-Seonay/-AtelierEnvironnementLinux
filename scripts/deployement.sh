#!/bin/bash

apt install sshpass -y

# Vérification que le fichier CSV est fourni en argument
if [ $# -ne 1 ]; then
    echo "Utilisation : $0 fichier.csv"
    exit 1
fi

csv_file="$1"

# Vérification de si le fichier existe
if [ ! -f "$csv_file" ]; then
    echo "Le fichier $csv_file n'existe pas."
    exit 1
fi

# Lecture du fichier CSV et attribution des valeurs aux variables
while IFS=',' read -r var value; do
    case "$var" in
        *)
            if [ -n "$var" ]; then
                eval "$var=\"$value\""
            fi
            ;;
    esac
done < "$csv_file"

# Affichage des valeurs des variables
echo "web = $web"
echo "bdd = $bdd"

# Fonction pour exécuter des commandes SSH avec sshpass
function command_ssh {
    [ ${#} -gt 0 ] || return 1
    sshpass -p root ssh -o StrictHostKeyChecking=no kidoly@$1 $2
}

# Connexion à la VM web
SUDOPASS="root"  # Remplacez par le mot de passe SSH de votre hôte distant

# Exemple : exécution de commandes SSH
command_ssh "$web" "echo $SUDOPASS | sudo -S apt update && sudo apt -y upgrade"
command_ssh "$web" "echo $SUDOPASS | sudo -S apt -y install php php-common php-cli php-fpm php-json php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath"
command_ssh "$web" "echo $SUDOPASS | sudo -S apt install apache2 -y"
command_ssh "$web" "echo $SUDOPASS | sudo -S chown -R $USER:www-data /var/www/html/"
command_ssh "$web" "echo $SUDOPASS | sudo -S chmod -R 770 /var/www/html/"

# Exemple : créer un répertoire sur l'hôte distant
command_ssh "$web" "echo $SUDOPASS | sudo -S mkdir /home/kidoly/test405"

# Exemple : afficher un message
command_ssh "$web" "echo 'Le script a terminé avec succès. Votre serveur est prêt.'"
exit

#connexion à la vm bdd
SUDOPASS="root"

command_ssh "$web" "echo $SUDOPASS | touch /home/kidoly/itworks8"

# Vérifie les mises à jour du système
command_ssh "$web" "echo $SUDOPASS |sudo -S apt update && sudo apt -y upgrade"

# Installation d'OpenSSL
command_ssh "$web" "echo $SUDOPASS |sudo -S apt install openssl -y"

# Installation de MariaDB
command_ssh "$web" "echo $SUDOPASS |sudo -S apt install mariadb-server php-mysql -y"

# On se connecte à MySQL
command_ssh "$web" "echo $SUDOPASS | sudo -S mysql --user=root <<MYSQL_SCRIPT
$PASSWORD=\$(openssl rand -base64 32)
# On change le mot de passe de l'utilisateur root
ALTER USER 'root'@'localhost' IDENTIFIED BY '\$PASSWORD';
FLUSH PRIVILEGES;
MYSQL_SCRIPT"

command_ssh "$web" "echo $SUDOPASS | echo "Le mot de passe root de MySQL a été modifié. Nouveau mot de passe : $PASSWORD"
exit

