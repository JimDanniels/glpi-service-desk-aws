# 001 — Respaldo *pull*: la máquina de respaldo va a buscar la copia

**Estado:** aceptada (aprobada por el jefe del área). Script del servidor en uso; copia externa en implementación.

## Contexto
GLPI corría en una sola instancia de AWS. Si se perdía la instancia, la cuenta o la base, se perdían todos los tickets.

## Decisión
1. El servidor arma una copia completa cada día a las 13:00 y conserva 3.
2. Una VM Ubuntu en la oficina entra con un usuario aparte, `respaldo`, y **descarga** la copia con `rsync` de lunes a viernes a las 13:30 (reintento a las 17:00). Guarda 14 días.
3. La llave de ese usuario queda amarrada a `rrsync -ro`: solo puede **leer** la carpeta de respaldos. Sin terminal, sin `sudo`, sin acceso al resto del servidor.

```
command="/usr/bin/rrsync -ro /var/backups/glpi",restrict ssh-ed25519 AAAA... respaldo-vm
```

## Alternativas
| Opción | Por qué no |
| --- | --- |
| *Push*: el servidor envía la copia a la oficina | El servidor tendría credenciales para llegar a la oficina; si lo toman, también llegan a las copias |
| Respaldo semanal | Se podían perder hasta 7 días de tickets |
| Windows con `scp` y el Programador de tareas | Restringir la llave a "solo leer una carpeta" es mucho más enredado que con `rrsync` |
| Copia a las 3:00 | La VM solo funciona en horario de oficina; a las 13:00 (almuerzo) GLPI casi no se usa |

## Consecuencias
- La llave de la VM no tiene contraseña (la usa `cron`); se compensa con la restricción de solo lectura.
- La VM tiene que estar encendida en horario de oficina. Con 3 copias en el servidor, un fin de semana apagada no pierde nada.
- Un respaldo protege contra la **pérdida**, no contra el robo: contra eso protege el endurecimiento del servidor.
