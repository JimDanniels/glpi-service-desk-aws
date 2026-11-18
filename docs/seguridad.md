# Checklist de endurecimiento

Medidas aplicadas en el servidor de producción, con el comando para comprobar cada una.

| Medida | Estado | Cómo se comprueba |
| --- | --- | --- |
| HTTPS obligatorio (Let's Encrypt) | ✅ | `curl -I http://soporte.example.com` → `301` a https |
| Renovación automática del certificado | ✅ | `sudo certbot renew --dry-run` |
| Cookie de sesión solo por HTTPS (`session.cookie_secure`) | ✅ | `curl -I https://soporte.example.com` → `secure; HttpOnly` |
| SSH solo con llave | ✅ | `sudo sshd -T \| grep passwordauthentication` → `no` |
| Fail2ban en SSH (5 fallos / 10 min → 1 h, creciente) | ✅ | `sudo fail2ban-client status sshd` |
| Instalador de GLPI retirado | ✅ | `curl -I https://soporte.example.com/install/install.php` → `404` |
| Cuentas de fábrica (`glpi`, `tech`, `normal`, `post-only`) desactivadas | ✅ | `SELECT name, is_active FROM glpi_users WHERE name IN (...)` |
| Permisos de `files`, `config`, `marketplace` = `www-data` | ✅ | `stat -c '%U:%G %n' /var/www/glpi/{files,config,marketplace}` |
| Parches de seguridad automáticos de Ubuntu | ✅ | `cat /etc/apt/apt.conf.d/20auto-upgrades` → dos líneas en `"1"` |
| Lista de puertos de AWS (Security Group): dejar solo 80, 443 y 22 | ⏳ | Consola de AWS (a cargo del administrador de la cuenta) |
| Menús ocultos por permisos, no por CSS | ✅ | Ver [decisión 004](decisiones/004-permisos-no-css.md) |

## Detalles que importan

- **El puerto 80 queda abierto:** lo usan la redirección a https y la renovación del certificado.
- **El instalador vuelve a aparecer en cada actualización de GLPI:** se retira de nuevo (se mueve fuera de la carpeta, no se borra).
- **Las cuentas de fábrica se desactivan, no se borran:** GLPI puede tenerlas enlazadas. Tenían contraseñas públicas y son lo primero que prueba un bot. `glpi-system` no se toca: GLPI la usa para sus tareas automáticas.
- **Iniciar sesión por la IP deja de funcionar** con `cookie_secure`. Es intencional: se entra siempre por el nombre.

## Riesgos que siguen abiertos

Ninguna medida cubre todo. Quedan: el robo de una llave o contraseña de administrador, fallas de seguridad de GLPI (se actualiza a mano) y engaños por correo. Se mitigan cuidando las llaves, actualizando GLPI y limitando el perfil Super-Admin a pocas personas.
