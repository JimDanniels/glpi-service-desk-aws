# 007 — SSH solo con llave + Fail2ban, sin restringir por IP

**Estado:** aceptada e implementada.

## Contexto
Los registros mostraron 58 intentos de acceso de bots al puerto 22 en tres días. La oficina tiene IP pública dinámica, y la empresa decidió no contratar una IP fija.

## Decisión
- SSH solo con llave (sin contraseña).
- Fail2ban: 5 fallos en 10 minutos → bloqueo de 1 hora, que crece con cada reincidencia. Ver [server/fail2ban/jail.local](../../server/fail2ban/jail.local).

## Alternativas
| Opción | Por qué no |
| --- | --- |
| Abrir el puerto 22 solo a la IP de la oficina | La IP cambia; un día dejaría fuera a los administradores |
| Excluir la oficina de Fail2ban (`ignoreip`) | Mismo problema: sin IP fija no hay qué excluir |

## Consecuencias
- Toda la oficina sale con la misma IP: 5 fallos desde cualquier equipo bloquean a todos por 1 hora. Se documentó cómo desbloquear (`fail2ban-client set sshd unbanip`).
- Costo cero; consumo mínimo.
