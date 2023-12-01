#!/bin/bash

sudo apt install sshpass -y

# Check if the flag file exists indicating the script has already been executed
if [ -f "$HOME/.script_iptables_flag" ]; then
    echo "The script has already been executed. Exiting."
    exit 0
fi

# Create the flag file to indicate that the script is being executed
touch "$HOME/.script_iptables_flag"

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
command_ssh "$web" "echo $SUDOPASS | sudo -S iptables -A INPUT -p tcp -i eth0 --dport 22 -j ACCEPT"
command_ssh "$web" "echo $SUDOPASS | sudo -S iptables -A INPUT -p tcp -i eth0 --dport 80 -j ACCEPT"
command_ssh "$web" "echo $SUDOPASS | sudo -S iptables -A INPUT -p tcp -i eth0 --dport 443 -j ACCEPT"
command_ssh "$web" "echo $SUDOPASS | sudo -S iptables -P INPUT DROP"
command_ssh "$bdd" "echo $SUDOPASS | sudo -S iptables -A INPUT -p tcp -i eth0 --dport 22 -j ACCEPT"
command_ssh "$bdd" "echo $SUDOPASS | sudo -S iptables -A INPUT -p tcp -i eth0 --dport 3306 -j ACCEPT"
command_ssh "$bdd" "echo $SUDOPASS | sudo -S iptables -P INPUT DROP"

