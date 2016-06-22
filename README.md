# Application Ruby on Rails for Radio Campus Grenoble

Cette application permet d'interagir avec une instance de logiciel Rivendell. Chaque interaction est causée par la réception d'une requête HTTP venant par exemple d'une application web de type [Disco](https://github.com/bpeynet/disco).

Cette application web est capable :
* de créer une cartouche dans Rivendell et d'importer le fichier mp3 associé
* de générer des statistiques quant à la diffusion de musique par Rivendell
* d'effectuer une rotation (Mise à jour des tags des cartouches qui ne sont plus assez récentes). En réalité, celle-ci est paramétrée pour l'effectuer quotidiennement.

## Paramétrage de l'application :
Modifier le fichier 'config/api.yml'
* Le paramètre 'api_key' peut être changé par un autre mot de passe mais doit être modifié alors aussi dans les paramètres de Disco.
* Le paramètre 'rivendell_host' doit contenir l’adresse IP de la machine Rivendell.
* Le paramètre 'rivendell_user' doit contenir le nom d’utilisateur de la base de données Rivendell.
* Le paramètre 'rivendell_password' doit contenir le mot de passe associé au nom d’utilisateur de la base de données Rivendell entré ci-dessus.
* Le paramètre 'rivendell_db_url' doit contenir le nom d’utilisateur de la base de données Rivendell '**user**', le mot de passe associé '**password**', l’adresse IP de la machine Rivendell '**ip**' et le nom de la base de données Rivendell concaténés sous la forme '**name**' : 'mysql://**user**:**password**@**ip**/**name**'.

