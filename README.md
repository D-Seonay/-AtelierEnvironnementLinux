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
Le rendu de ce TP se fera en fournissant les scripts réalisés ainsi qu'un rapport expliquant les différentes étapes de mise en place de l'environnement Linux.



## Auteur
[@D-Seonay](https://github.com/D-Seonay) [@jojosashaw](https://github.com/jojosashaw) [@Kidoly](https://github.com/Kidoly)
