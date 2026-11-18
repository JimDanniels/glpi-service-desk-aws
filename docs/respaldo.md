# Estrategia de respaldo

El razonamiento completo está en la [decisión 001](decisiones/001-respaldo-pull.md).

## Qué incluye cada copia

| Archivo | Contenido | Tamaño inicial |
| --- | --- | --- |
| `glpi.sql.gz` | Base completa, con rutinas y disparadores | 2,9 MB (58 MB sin comprimir) |
| `archivos.tar.gz` | `files/` y `config/`, sin `_cache` ni `_sessions` | 1,9 MB |
| `SHA256SUMS` | Huellas para verificar la integridad | — |

Cada copia es una **foto completa** del sistema. Para recuperar todo basta la más reciente.

## Horarios y retención

| Dónde | Cuándo | Copias |
| --- | --- | --- |
| Servidor | Todos los días, 13:00 | 3 (cubre un fin de semana) |
| VM de la oficina (*pull*) | Lunes a viernes 13:30, reintento 17:00 | 14 días |
| Histórico | Antes de que la VM las borre | Por definir |

## El script

[server/backup/respaldo-glpi.sh](../server/backup/respaldo-glpi.sh):

- `set -euo pipefail`: ante cualquier error se detiene; `pipefail` evita una copia vacía si falla `mysqldump`.
- `trap ... ERR`: si algo falla, anota la línea en el registro y borra la copia incompleta.
- `--single-transaction`: foto consistente sin bloquear GLPI.
- `umask 027`: las copias solo las leen root y el grupo `respaldo`.
- Rotación: `head -n -3` deja solo las tres más nuevas.

## Prueba manual

```bash
sudo /usr/local/sbin/respaldo-glpi.sh
sudo cat /var/log/respaldo-glpi.log
# 2026-11-16 16:53:40 Respaldo OK: /var/backups/glpi/2026-11-16 (4.8M)
sudo bash -c 'cd /var/backups/glpi/$(date +%F) && sha256sum -c SHA256SUMS'   # OK, OK
sudo gunzip -t /var/backups/glpi/$(date +%F)/glpi.sql.gz && echo "base OK"
```

## Usuario de solo lectura para el *pull*

```bash
sudo adduser --system --group --shell /bin/sh --home /home/respaldo respaldo
sudo chgrp -R respaldo /var/backups/glpi
sudo chmod 2750 /var/backups/glpi      # el 2 (setgid) hace que las copias nuevas hereden el grupo
# /home/respaldo/.ssh/authorized_keys (una sola línea, permisos 600):
# command="/usr/bin/rrsync -ro /var/backups/glpi",restrict ssh-ed25519 AAAA... respaldo-vm
```

## Crecimiento

El registro anota el tamaño de cada copia. Si una copia pasa de 1 GB, el plan se ajusta: base completa diaria + adjuntos con `rsync` incremental, o un disco más grande.

## Siguiente paso propuesto

Una copia en un bucket de **S3 con Object Lock**, que impide borrar o modificar las copias durante un plazo, subida por la VM con un usuario de AWS que **solo puede subir** (sin leer ni borrar). Así el servidor no guarda credenciales de S3.
