#!/bin/bash
################################################
#
# Respaldo diferencial para todos los directorios y bases de datos de un  (..)
# servidor Web.
# El respaldo diario segmenta todas las Bases de datos en archivos.
# El script crea un directorio para cada servidores con día y fecha corriente.
# @author original: Per Lasse Baasch (http://skycube.net)
# Mejorado: José Pino (@bobbylechuga) para DSIA-ULA, editado para su uso libre en: github.com/alphacity
# @Version: 2015
# NOTA: MySQL y gzip deben estar instalados
# Ejecutar como Root (cronjob) para tener permisos totales de escritura
# El servidor de destino debe contener la clave pública del origen para la relación de confianza
# http://blog.desdelinux.net/ssh-sin-password-solo-3-pasos/
################################################
source config.sh

#Directorio donde se guardarán los respaldos año/mes/dia.tar
basedir="/home/path/respaldos/$(hostname -s)"
annomes=`date +%Y`/`date +%m`
fullpath="$basedir/$annomes"
instanfilename=`date +%d`;

# Directorios a respaldar
backup_me="/var/www/html/"

#Crea el directorio destino sólo si no existe año/mes
mkdir -p "$fullpath"

#Checkear que existe el archivo full.tar correspondiente a cada mes
#Si no existe, por ejemplo, es el día 1 del mes, crea full.tar.gz
cd "$fullpath"
if [ ! -f full.tar.gz ]; then
  echo "Creando respaldo total"
  tar -czf full.tar.gz -S -P --exclude="$backup_me/cache" --listed-incremental=snapshot $backup_me
  mysqldump --user=$USER --password=$PASSWORD --all-databases --events --ignore-table=mysql.event > fullBDs.sql
  # DUMP de todas las Bases de datos menos: information_schema, information_schema, test y algunas propias
  MYSQL=$(mysql -N --user=$USER --password=$PASSWORD <<<"SHOW DATABASES" | grep -v bdpropiaignorar | grep -v information_schema | grep -v test | grep -v performance_schema | tr "\n" " ")
  mysqldump -v --user=$USER --password=$PASSWORD --databases  --skip-lock-tables ${MYSQL} > fullBDs.sql

  # Copiar por SCP a un servidor de respaldos
  # El servidor de destino debe contener la clave pública del origen para la relación de confianza
  # http://blog.desdelinux.net/ssh-sin-password-solo-3-pasos/

  ssh usuario@origen "mkdir -p $fullpath" && scp -r full.tar.gz fullBDs.sql "usuario@destino:$fullpath"

else
  #Si existe, crea el archivo tar.gz diario y el directorio destino
  #para todas las bases de datos por separado

  tar -czf dia-$instanfilename.tar.gz -S -P --exclude="$backup_me/cache" --listed-incremental=snapshot $backup_me
  mkdir -p dia-$instanfilename
  mv dia-$instanfilename.tar.gz dia-$instanfilename/

  cd dia-$instanfilename
  databases=`mysql --user=$USER --password=$PASSWORD -e "SHOW DATABASES;" | tr -d "| " | grep -v Database`
  for db in $databases; do
    if [[ "$db" != "information_schema" ]] && [[ "$db" != "performance_schema" ]] && [[ "$db" != "bdpropiaignorar" ]] && [[ "$db" != _* ]] ; then
      echo "Respaldando Bases de datos: $db"
      mysqldump --force --opt --user=$USER --password=$PASSWORD --databases --events --ignore-table=mysql.event $db > dbbackup-$db.sql
      #gzip $OUTPUT/dbbackup-$TIMESTAMP-$db.sql
    fi
  done
  cd ..
  pwd
  ssh usuario@origen "mkdir -p $fullpath/dia-$instanfilename" && scp -r "$fullpath/dia-$instanfilename/"* "usuario@destino:$fullpath/dia-$instanfilename"
fi
