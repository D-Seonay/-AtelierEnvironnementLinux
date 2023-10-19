#!/bin/bash

ip_address_web='10.0.2.4'
ip_address_bdd='10.0.2.15'

current_ip=$(hostname -I)

if["$current_ip" = "$ip_address_web"];
then
    sudo iptables -A INPUT -p tcp -i eth0 --dport 22 -j ACCEPT
    sudo iptables -A INPUT -p tcp -i eth0 --dport 80 -j ACCEPT
    sudo iptables -A INPUT -p tcp -i eth0 --dport 443 -j ACCEPT
    echo "Machine avec adresse IP correspondant à web. Règles pour serveur Web ajoutées."
    sudo iptables -P INPUT DROP
elif["$current_ip" = "$ip_address_bdd"];
    sudo iptables -A INPUT -p tcp -i eth0 --dport 22 -j ACCEPT
    sudo iptables -A INPUT -p tcp -i eth0 --dport 3306 -j ACCEPT
    echo "Machine avec adresse IP correspondant à bdd. Règles pour serveur de base de données ajoutées."
    sudo iptables -P INPUT DROP
fi
