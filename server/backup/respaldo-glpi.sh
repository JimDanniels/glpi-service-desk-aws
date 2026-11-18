#!/usr/bin/env bash
# respaldo-glpi.sh — respaldo diario de GLPI (base de datos + files + config)
# Ubicación: /usr/local/sbin/respaldo-glpi.sh (chmod 750). Se ejecuta con cron a las 13:00.
set -euo pipefail          # se detiene ante cualquier error; pipefail evita copias vacías
umask 027                  # archivos legibles solo por root y su grupo

DESTINO="/var/backups/glpi"
FECHA="$(date +%F)"
CARPETA="$DESTINO/$FECHA"
REGISTRO="/var/log/respaldo-glpi.log"
COPIAS=3                   # copias que se conservan en el servidor (cubre un fin de semana)

log() { echo "$(date '+%F %T') $*" >> "$REGISTRO"; }
trap 'log "ERROR en la línea $LINENO, se borra la copia incompleta"; rm -rf "$CARPETA"' ERR

log "Inicio del respaldo"
mkdir -p "$CARPETA"

# Foto consistente de la base sin bloquear GLPI; incluye el disparador de numeración
mysqldump --single-transaction --routines --triggers glpi | gzip > "$CARPETA/glpi.sql.gz"

# Adjuntos, traducción propia y config (incluye la llave interna de GLPI, glpicrypt.key).
# _cache y _sessions se excluyen: GLPI los regenera.
tar -czf "$CARPETA/archivos.tar.gz" -C /var/www/glpi \
    --exclude='files/_cache' --exclude='files/_sessions' \
    files config

# Huellas para comprobar que la copia llega intacta
cd "$CARPETA"
sha256sum glpi.sql.gz archivos.tar.gz > SHA256SUMS

# Conserva solo las COPIAS más recientes
ls -1d "$DESTINO"/20*/ | sort | head -n -"$COPIAS" | xargs -r rm -rf

log "Respaldo OK: $CARPETA ($(du -sh "$CARPETA" | cut -f1))"
