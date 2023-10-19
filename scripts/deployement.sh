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

#connexion à la vm web
SUDOPASS="root"
echo $SUDOPASS
echo $web

sshpass -v -p $SUDOPASS ssh kidoly@$web <<EOF

# Vérifie les mises à jour du système
echo "$SUDOPASS" | sudo apt update && sudo apt -y upgrade

# Installe PHP et ses extensions
echo "$SUDOPASS" | sudo apt -y install php php-common php-cli php-fpm php-json php-pdo php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath

# Installe Apache
echo "$SUDOPASS" | sudo apt install apache2 -y

# Donne les droits à l'utilisateur sur le dossier Apache
echo "$SUDOPASS" | sudo chown -R $USER:www-data /var/www/html/
echo "$SUDOPASS" | sudo chmod -R 770 /var/www/html/

echo "$SUDOPASS" | echo "Le script a terminé avec succès. Votre serveur web est prêt."

exit
EOF
#connexion à la vm bdd
SUDOPASS="root"
sshpass -v -p$SUDOPASS ssh -tt kidoly@$bdd  <<EOF

echo "$SUDOPASS" | touch /home/kidoly/itworks8

# Vérifie les mises à jour du système
echo "$SUDOPASS" | sudo apt update && sudo apt -y upgrade

# Installation d'OpenSSL
echo "$SUDOPASS" | sudo apt install openssl -y

# Installation de MariaDB
echo "$SUDOPASS" | sudo apt install mariadb-server php-mysql -y

# On se connecte à MySQL
echo "$SUDOPASS" | sudo mysql --user=root <<MYSQL_SCRIPT
$PASSWORD = "$(openssl rand -base64 32)"
# On change le mot de passe de l'utilisateur root
ALTER USER 'root'@'localhost' IDENTIFIED BY '$PASSWORD';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Le mot de passe root de MySQL a été modifié. Nouveau mot de passe : $PASSWORD"
exit
EOF
