# caronte

Colección de Shells para agilizar rutinas de respaldos incrementales, diferenciales y versionados. Originalmente creados para la DSIA-ULA y editados para github.com/alphacityco/

# carontegit.sh
Reslpaldos diferenciales. Mensualmente crea una copia total del o los servicios webs a respaldar (bases de datos seleccionadas incluídas) y los copia en un servidor de respaldo vía SCP. Diariamente crea un tar.gz con los archivos que cambiaron y copia todas las bases de datos seleccionadas separadas en archivos para facilitar la importación de la información. 

# carontediff.sh
Diariamente versiona y reslpalda un servicio web y su base de datos en un repositorio privado en Bitbucket.org.

Ejecutar con un cronjob, ejemplo:

00 4 * * * cd /usr/local/src/ && ./carontegit.sh

(Se ejecutará todos los días a las 04:00 am)
