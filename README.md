
# PawCare - Gestion de Refuges Animaux



Application web développée en Python (Flask) permettant la gestion centralisée d'un réseau de refuges de la SPA, le suivi des animaux, des soins vétérinaires ainsi que la gestion des adoptions et des transferts.



## Fonctionnalités



* Gestion des refuges et des employés (espace privé, connexion sécurisée)

* Fiches détaillées des animaux, suivi des vaccins et historique complet des soins

* Organisation des adoptions et transfert d'animaux entre refuges

* Base de données relationnelle SQL avec script de restauration inclus



## Structure du projet



* `main.py` : Serveur principal et gestion des routes web

* `db.py` : Gestion des connexions et requêtes à la base de données

* `dump-pawcare.sql` : Script d'initialisation et données de la base SQL

* `templates/` : Vues HTML (accueil, adoptions, fiches animaux, soins, refuges)

* `static/` : Feuilles de style CSS et assets graphiques (logo)

* `pawcare-rapport.pdf` : Rapport d'analyse et d'architecture du projet



## Installation et Lancement



1. Cloner le dépôt :

   ```bash

   git clone https://github.com/nesm4/pawcare.git

   cd pawcare

   ```



2. Importer la base de données :

   Exécuter le script `dump-pawcare.sql` dans votre SGBD.



3. Lancer l'application :

   ```bash

   python main.py

   ```

