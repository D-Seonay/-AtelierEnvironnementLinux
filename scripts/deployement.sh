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
command_ssh "$web" "echo $SUDOPASS | sudo -S apt-get update && sudo apt -y upgrade"
command_ssh "$web" "echo $SUDOPASS | sudo -S apt-get -y install php8.2 php8.2-cli php8.2-common php8.2-imap php8.2-redis php8.2-snmp php8.2-xml php8.2-mysqli php8.2-zip php8.2-mbstring php8.2-curl libapache2-mod-php"
command_ssh "$web" "echo $SUDOPASS | sudo -S apt-get install apache2 -y"
command_ssh "$web" "echo $SUDOPASS | sudo -S systemctl enable apache2"
command_ssh "$web" "echo $SUDOPASS | sudo -S systemctl start apache2"
command_ssh "$web" "echo $SUDOPASS | sudo -S chown -R $USER:www-data /var/www/html/"
command_ssh "$web" "echo $SUDOPASS | sudo -S chmod -R 770 /var/www/html/"

# Download and Install WordPress
command_ssh "$web" "cd /var/www/html"
command_ssh "$web" "wget https://wordpress.org/latest.zip"
command_ssh "$web" "unzip latest.zip"
command_ssh "$web" "rm latest.zip"
command_ssh "$web" "chown -R www-data:www-data wordpress/"
command_ssh "$web" "cd wordpress/"
command_ssh "$web" "find . -type d -exec chmod 755 {} \;"
command_ssh "$web" "find . -type f -exec chmod 644 {} \;"

# Create Apache Virtual Host File
command_ssh "$web" "cd /etc/apache2/sites-available/"
command_ssh "$web" "touch wordpress.conf"
command_ssh "$web" "echo '<VirtualHost *:80>' > wordpress.conf"
command_ssh "$web" "echo 'ServerName yourdomain.com' >> wordpress.conf"
command_ssh "$web" "echo 'DocumentRoot /var/www/html/wordpress' >> wordpress.conf"
command_ssh "$web" "echo '<Directory /var/www/html/wordpress>' >> wordpress.conf"
command_ssh "$web" "echo 'AllowOverride All' >> wordpress.conf"
command_ssh "$web" "echo '</Directory>' >> wordpress.conf"
command_ssh "$web" "echo 'ErrorLog ${APACHE_LOG_DIR}/error.log' >> wordpress.conf"
command_ssh "$web" "echo 'CustomLog ${APACHE_LOG_DIR}/access.log combined' >> wordpress.conf"
command_ssh "$web" "echo '</VirtualHost>' >> wordpress.conf"

# Restart Apache
command_ssh "$web" "echo $SUDOPASS | sudo -S systemctl restart apache2"


# Exemple : créer un répertoire sur l'hôte distant
command_ssh "$web" "echo $SUDOPASS | sudo -S mkdir /home/kidoly/test405"

# Exemple : afficher un message
command_ssh "$web" "echo 'Le script a terminé avec succès. Votre serveur est prêt.'"

#connexion à la vm bdd
SUDOPASS="root"

# Vérifie les mises à jour du système
command_ssh "$bdd" "echo $SUDOPASS | sudo -S apt-get update && echo $SUDOPASS | sudo -S apt-get -y upgrade"

# Installation d'OpenSSL
command_ssh "$bdd" "echo $SUDOPASS | sudo -S apt-get install openssl -y"

# Installation de MariaDB
command_ssh "$bdd" "echo $SUDOPASS | sudo -S apt-get install mariadb-server mariadb-client php-mysql -y"
command_ssh "$bdd" "echo $SUDOPASS | sudo -S start mariadb"
command_ssh "$bdd" "echo $SUDOPASS | sudo -S systemctl enable mariadb"

# Création d'un mot de passe aléatoire pour l'utilisateur root de MySQL
command_ssh "$bdd" "MYSQL_PASSWORD=\$(openssl rand -base64 32)"

# On se connecte à MySQL et change le mot de passe de l'utilisateur root
command_ssh "$bdd" "echo $SUDOPASS | mysql --user=root -e \"CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '\$MYSQL_PASSWORD'; CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost'; FLUSH PRIVILEGES;\""

command_ssh "$bdd" "echo $SUDOPASS | echo \"Le mot de passe root de MySQL a été modifié. Nouveau mot de passe : \$PASSWORD\""

# Copy your public key to the "web" and "bdd" servers
command_ssh "$web" "echo $SUDOPASS | sudo -S mkdir -p /root/.ssh"
command_ssh "$web" "echo $SUDOPASS | sudo -S echo 'YOUR_PUBLIC_KEY' >> /root/.ssh/authorized_keys"
command_ssh "$bdd" "echo $SUDOPASS | sudo -S mkdir -p /root/.ssh"
command_ssh "$bdd" "echo $SUDOPASS | sudo -S echo 'YOUR_PUBLIC_KEY' >> /root/.ssh/authorized_keys"

# Disable password-based authentication on the "web" and "bdd" servers
command_ssh "$web" "echo $SUDOPASS | sudo -S sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"
command_ssh "$bdd" "echo $SUDOPASS | sudo -S sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"

# Reload the SSH service on the "web" and "bdd" servers
command_ssh "$web" "echo $SUDOPASS | sudo -S systemctl reload sshd"
command_ssh "$bdd" "echo $SUDOPASS | sudo -S systemctl reload sshd"
exit

