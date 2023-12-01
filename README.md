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


# Script de déploiement

Ce script est conçu pour les tâches de déploiement automatisées via SSH, répondant à divers scénarios basés sur des arguments de ligne de commande.

## Utilisation

```bash
./deploy_script.sh fichier.csv {web|bdd|deploywp}
```

fichier.csv : Le fichier CSV contenant les informations de configuration pour le déploiement.
{web|bdd|deploywp} : argument de ligne de commande spécifiant la tâche de déploiement.

## Instruction

1. **Fichier drapeau :**
   - Le script utilise un fichier indicateur (\$HOME/.script_deployement_flag) pour garantir qu'il n'est pas exécuté plusieurs fois. Si le fichier flag existe, le script se termine.

2. **Fichier CSV :**
   - Assurez-vous qu'un fichier CSV valide est fourni comme argument lors de l'exécution du script. Le fichier CSV doit contenir des informations de configuration pour le déploiement.

3. **Tâches de déploiement :**
   - Le script prend en charge trois tâches de déploiement :
     - web : Déploie un serveur web avec PHP.
     - bdd : Déploie un serveur de base de données et le configure.
     - déployerwp : installe WordPress sur le serveur Web, configure la base de données et effectue la configuration SSH.

4. **Configuration SSH :**
   - Le script configure SSH sur les serveurs cibles en copiant la clé publique sur les hôtes distants et en désactivant l'authentification par mot de passe.

5. **Considérations de sécurité :**
   - Avant de désactiver l'authentification par mot de passe, assurez-vous que l'authentification par clé SSH est configurée et testée avec succès.

## Exemples
**Déploiement du serveur Web**
./deploy_script.sh fichier.csv web

**Déploiement du serveur de base de données**
./deploy_script.sh fichier.csv bdd

**Déploiement WordPress
./deploy_script.sh fichier.csv bdd

## Remarques
Remplacez 'YOUR_PUBLIC_KEY' par votre clé publique réelle dans le script.
Remplacez 'SUDOPASS' par le mot de passe réel dans le script.

## Screenshots
![If the script has been already use](https://github.com/D-Seonay/AtelierEnvironnementLinux/blob/main/already.png)

## Auteur
[@D-Seonay](https://github.com/D-Seonay) [@jojosashaw](https://github.com/jojosashaw) [@Kidoly](https://github.com/Kidoly)
