# Lecciones aprendidas

Problemas reales del proyecto, cómo se diagnosticaron y qué quedó como regla.

## Servidor y despliegue

**Certbot dijo "éxito" y la redirección a HTTPS no funcionaba.**
`curl -I http://…` respondía `200` en vez de `301`. El único `RewriteEngine On` estaba dentro del bloque `<Directory>` de GLPI, y ese interruptor vale solo para su bloque. Las reglas de certbot quedaron fuera, sin interruptor. Se agregó otro `RewriteEngine On` a nivel del VirtualHost.
→ *Regla: comprobar con `curl -I`, no confiar en el mensaje de éxito.*

**Un archivo de Apache quedó cortado al editarlo con nano.**
`apache2ctl configtest` falló y el `reload` no aplicó nada: Apache siguió funcionando con la configuración anterior. Se restauró desde el `.bak` en segundos.
→ *Regla: respaldo antes de editar → `configtest` → `reload`. Nunca `restart` con la configuración rota: Apache no vuelve a encender. Para cambios puntuales, `sed` o `tee` con here document en vez de un editor.*

**El ícono de la pestaña desapareció al migrar a AWS.**
Vivía en un archivo de Apache, no en la base de datos, así que no viajó con el respaldo.
→ *Regla: documentar cada ajuste según la capa donde vive ([arquitectura.md](arquitectura.md#las-tres-capas-donde-vive-la-configuración)).*

**`sudo cd /var/backups/glpi` → "Permission denied".**
`sudo` aplica solo al comando siguiente; `cd` lo ejecuta la terminal con el usuario normal.
→ *Regla: `sudo bash -c 'cd … && …'`.*

**Un comando de Windows pegado en la terminal de la VM contó como intento fallido para Fail2ban.**
Tres terminales (Windows, VM y servidor) se veían casi iguales.
→ *Regla: mirar el inicio de la línea antes de pegar. Y recordar que toda la oficina comparte IP pública: 5 fallos bloquean a todos.*

## Red

**Dos notebooks conectados al mismo switch no se veían entre sí.**
Se descartó, en orden: redes distintas (`ipconfig`), salida por Wi-Fi, cortafuegos de Windows (un ping "inaccesible" desde la IP propia significa que la pregunta ARP no tuvo respuesta, cosa que un cortafuegos no causa) y VirtualBox (dos equipos físicos tampoco se veían). La causa era física: el switch tenía un selector en modo **Extend**, que alarga el alcance de los puertos PoE a cambio de aislarlos entre sí. En **Standard** todo funcionó.
→ *Regla: revisar el hardware antes de la configuración. "Inaccesible" no es lo mismo que "tiempo agotado".*

## Correo

**Las notificaciones salían desde la VM y no desde AWS, con la misma cuenta y contraseña.**
Eso descartó GLPI, la contraseña y el permiso de SMTP de la cuenta. Lo único distinto era **desde dónde** salía la conexión: Microsoft 365 aceptaba el inicio de sesión desde la oficina y lo rechazaba desde un centro de datos en otro país (acceso condicional / protección por ubicación).
→ *Regla: aislar una variable a la vez. La salida definitiva es un buzón compartido con SMTP+OAuth, porque Microsoft está retirando la autenticación con contraseña para SMTP.*

**Un correo que nunca llegaba, sin ningún error.**
La plantilla no tenía traducción predeterminada: GLPI simplemente no la envía.
→ *Regla: después de editar una plantilla, enviar un ticket de prueba y revisar la cola.*

## GLPI

**Antes de iniciar sesión, la traducción propia no se aplicaba.**
GLPI usa el idioma del navegador en esa pantalla, no el configurado. Se resolvió con enlaces simbólicos de cada variante de español al mismo archivo ([glpi/locales](../glpi/locales/README.md)).
→ *Regla: leer el código cuando algo "debería funcionar"; el problema no estaba en el archivo, sino en cuándo se aplica.*

**Borrar los tickets de prueba no devolvió sus números.**
El contador AT/IN siguió avanzando.
→ *Regla: después de cada prueba, retroceder el contador a mano.*

**La numeración ya estaba funcionando y se estaba por diseñar de nuevo.**
→ *Regla: antes de diseñar algo, revisar si ya existe.*

**Un colaborador dejó de ver el formulario.**
Se había perdido el perfil en los Controles de acceso del formulario, y GLPI esconde la tarjeta sin avisar.
→ *Regla: ante "no veo el formulario", revisar primero los Controles de acceso.*

**Las cuentas de fábrica estaban activas en producción.**
Nunca se habían usado, pero tienen contraseñas públicas y son lo primero que prueba un bot.
→ *Regla: revisarlas apenas el sitio es público.*

## Proceso

- **Una afirmación en un correo se comprueba antes de enviarla.** La región del servidor se confirmó consultando al propio servidor (servicio de metadatos de AWS), no de memoria.
- **Antes de limitar un puerto a una IP, comprobar que esa IP sea fija.**
- **Un respaldo protege contra la pérdida, no contra el robo.** Cada capa de seguridad cubre un riesgo distinto.
- **Bitácora diaria:** qué se hizo, dónde, por qué y cómo se probó. Fue la base de toda la documentación.
