#!/bin/bash

# Check if the flag file exists indicating the script has already been executed
if [ -f "$HOME/.script_deployement_flag" ]; then
    echo "The script has already been executed. Exiting."
    exit 0
fi

# Create the flag file to indicate that the script is being executed
touch "$HOME/.script_deployement_flag"

apt install sshpass -y

# Checking that the CSV file is provided as an argument
if [ $# -ne 1 ]; then
    echo "Utilisation : $0 fichier.csv"
    exit 1
fi

csv_file="$1"

# Checking if the file exists
if [ ! -f "$csv_file" ]; then
    echo "Le fichier $csv_file n'existe pas."
    exit 1
fi

# Reading the CSV file and assigning values ​​to variables
while IFS=',' read -r var value; do
    case "$var" in
        *)
            if [ -n "$var" ]; then
                eval "$var=\"$value\""
            fi
            ;;
    esac
done < "$csv_file"

# Displaying variable values
echo "web = $web"
echo "bdd = $bdd"

# Function to execute SSH commands with sshpass
function command_ssh {
    [ ${#} -gt 0 ] || return 1
    sshpass -p root ssh -o StrictHostKeyChecking=no kidoly@$1 $2
}

# Password use on both remote host
SUDOPASS="root"  # Replace with your remote host's SSH password
YOUR_PUBLIC_KEY="test" # Replace with your public key

case "$1" in 
    web)
        command_ssh "$web" "echo $SUDOPASS | sudo -S apt-get update && sudo apt -y upgrade"
        command_ssh "$web" "echo $SUDOPASS | sudo -S apt-get -y install php8.2 php8.2-cli php8.2-common php8.2-imap php8.2-redis php8.2-snmp php8.2-xml php8.2-mysqli php8.2-zip php8.2-mbstring php8.2-curl libapache2-mod-php"
        command_ssh "$web" "echo $SUDOPASS | sudo -S apt-get install apache2 -y"
        command_ssh "$web" "echo $SUDOPASS | sudo -S systemctl enable apache2"
        command_ssh "$web" "echo $SUDOPASS | sudo -S systemctl start apache2"
        command_ssh "$web" "echo $SUDOPASS | sudo -S chown -R $USER:www-data /var/www/html/"
        command_ssh "$web" "echo $SUDOPASS | sudo -S chmod -R 770 /var/www/html/"
        ;;
    deploywp)
    
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
        ;;
    bdd)
        
        # Checks for system updates
        command_ssh "$bdd" "echo $SUDOPASS | sudo -S apt-get update && echo $SUDOPASS | sudo -S apt-get -y upgrade"
        
        # Installing OpenSSL
        command_ssh "$bdd" "echo $SUDOPASS | sudo -S apt-get install openssl -y"
        
        # Installing MariaDB
        command_ssh "$bdd" "echo $SUDOPASS | sudo -S apt-get install mariadb-server mariadb-client php-mysql -y"
        command_ssh "$bdd" "echo $SUDOPASS | sudo -S start mariadb"
        command_ssh "$bdd" "echo $SUDOPASS | sudo -S systemctl enable mariadb"
        
        # Creating a random password for the MySQL root user
        command_ssh "$bdd" "MYSQL_PASSWORD=\$(openssl rand -base64 32)"
        
        # We connect to MySQL and change the password of the root user
        command_ssh "$bdd" "echo $SUDOPASS | mysql --user=root -e \"CREATE USER 'wordpress'@'localhost' IDENTIFIED BY '\$MYSQL_PASSWORD'; CREATE DATABASE wordpress; GRANT ALL PRIVILEGES ON wordpress.* TO 'wordpress'@'localhost'; FLUSH PRIVILEGES;\""
        
        command_ssh "$bdd" "echo $SUDOPASS | echo \"Le mot de passe root de MySQL a été modifié. Nouveau mot de passe : \$PASSWORD\""
        
        # Copy your public key to the "web" and "bdd" servers
        command_ssh "$web" "echo $SUDOPASS | sudo -S mkdir -p /root/.ssh"
        command_ssh "$web" "echo $SUDOPASS | sudo -S echo '$YOUR_PUBLIC_KEY' >> /root/.ssh/authorized_keys"
        command_ssh "$bdd" "echo $SUDOPASS | sudo -S mkdir -p /root/.ssh"
        command_ssh "$bdd" "echo $SUDOPASS | sudo -S echo '$YOUR_PUBLIC_KEY' >> /root/.ssh/authorized_keys"
        
        # Disable password-based authentication on the "web" and "bdd" servers
        command_ssh "$web" "echo $SUDOPASS | sudo -S sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"
        command_ssh "$bdd" "echo $SUDOPASS | sudo -S sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config"
        
        # Reload the SSH service on the "web" and "bdd" servers
        command_ssh "$web" "echo $SUDOPASS | sudo -S systemctl reload sshd"
        command_ssh "$bdd" "echo $SUDOPASS | sudo -S systemctl reload sshd"
        ;;
    *)
        echo "Utilisation : $0 {web|bdd|deploywp}"
        exit 1
        ;;
esac
exit 0

