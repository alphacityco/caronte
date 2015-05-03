#!/bin/bash
################################################
#
# Sencillo script que versiona y respalda el contenido de un directorio +
# más un dump de la base de datos en un repositorio en Bitbucket
# @author: José Pino (@bobbylechuga
# @Version: 2015
# NOTE: Git y MySQL deben estar instalados
# Ejecutar con un cronjob, ejemplo:
# 00 4 * * * cd /usr/local/src/ && ./carontegit.sh
# (Ejecutar todos los días a las 04:00 am)
################################################

source config.sh

repo="/var/www/html/webarespadar"
backup_date=`date +%d%m%Y-%H%M`
cd $repo
mysqldump --user=$USER --password=$PASSWORD BD --events > "$repo"/bds/bdbucket.sql
cd $repo && git add -A;
git commit -m "Respaldo de la fecha $backup_date" && git push origin master
