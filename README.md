# TP Atelier Environnement Linux

## Table des matières
1. [Consignes](#consignes)
2. [Rendu](#rendu)
3. [Auther](#auteur)

## Consignes
Il vous est demandé de réaliser plusieurs scripts:
- Un script de déploiement automatique via ssh qui doit réagir à plusieurs arguments:
    - Un argument web, pour déployer un serveur Web + PHP
    - Un argument bdd, pour déployer un serveur de bases de données et le configurer proprement
    - Un argument deploywp, qui doit:
        - installer wordpress sur la vm web
        - ajouter base de données, utilisateur et mot de passe sur la vm base de données
    - le script doit aussi configurer proprement SSH (copier votre clef publique, désactiver l'authentification par login/mot de passe)
- Un script de backup, qui doit, suivant le rôle de chaque machine, sauvegarder des choses différentes (exemple: la base de données, le site web, etc)
- Un script qui doit déployer - et rendre persistantes - des règles iptables de base suivant le rôle de la machine

Tous vos scripts doivent vérifier qu'ils n'ont pas déjà été exécutés. Pour cela, vous pouvez par exemple laisser un fichier dans le $HOME de votre utilisateur sur chaque VM et tester la présence de ce fichier.

Le PDF avec les consignes : [PDF](EPSISN2TPAtelierEnvironnementLinux.pdf)

## Rendu


# Deployment Script

This script is designed for automated deployment tasks via SSH, catering to various scenarios based on command-line arguments.

## Usage

```bash
./deploy_script.sh fichier.csv {web|bdd|deploywp}
```

fichier.csv: The CSV file containing configuration information for deployment.
{web|bdd|deploywp}: Command-line argument specifying the deployment task.

## Instruction

1. **Flag File:**
   - The script utilizes a flag file (\$HOME/.script_deployement_flag) to ensure it is not executed multiple times. If the flag file exists, the script exits.

2. **CSV File:**
   - Ensure that a valid CSV file is provided as an argument when executing the script. The CSV file should contain configuration information for the deployment.

3. **Deployment Tasks:**
   - The script supports three deployment tasks:
     - web: Deploys a web server with PHP.
     - bdd: Deploys a database server and configures it.
     - deploywp: Installs WordPress on the web server, configures the database, and performs SSH configuration.

4. **SSH Configuration:**
   - The script configures SSH on the target servers by copying the public key to the remote hosts and disabling password-based authentication.

5. **Security Considerations:**
   - Before disabling password-based authentication, ensure that SSH key-based authentication is set up and tested successfully.

## Examples
**Web Server Deployement**
./deploy_script.sh fichier.csv web

**Database Server Deployement**
./deploy_script.sh fichier.csv bdd

**WordPress Deployement
./deploy_script.sh fichier.csv bdd

## Notes
Replace 'YOUR_PUBLIC_KEY' with your actual public key in the script.
Replace 'SUDOPASS' with the actual password in the script.


## Auteur
[@D-Seonay](https://github.com/D-Seonay) [@jojosashaw](https://github.com/jojosashaw) [@Kidoly](https://github.com/Kidoly)
