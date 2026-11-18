# Runbook: recuperación ante la pérdida del servidor

Lo lento es preparar el servidor; restaurar los datos toma segundos (copias de pocos MB).

1. **Nueva instancia.** Crear una instancia Ubuntu y asignarle la IP elástica. El DNS no cambia.
2. **Instalar la misma versión de GLPI** que tenía producción, con Apache, PHP y MariaDB. La versión se consulta y anota después de cada actualización:
   ```bash
   grep -m1 GLPI_VERSION /var/www/glpi/inc/define.php
   ```
3. **Traer la última copia** desde la VM y verificarla:
   ```bash
   sha256sum -c SHA256SUMS
   ```
4. **Restaurar la base:**
   ```bash
   gunzip < glpi.sql.gz | sudo mysql glpi
   ```
5. **Restaurar los archivos:**
   ```bash
   sudo tar -xzf archivos.tar.gz -C /var/www/glpi
   sudo mkdir -p /var/www/glpi/files/_cache /var/www/glpi/files/_sessions
   sudo chown -R www-data:www-data /var/www/glpi/files /var/www/glpi/config
   ```
6. **Rehacer la capa del servidor** (no viaja con el respaldo): sitios de Apache, HTTPS con certbot, `cookie_secure`, ícono de la pestaña, Fail2ban, SSH con llave, retirar el instalador y reinstalar el script de respaldo con su cron. Lista completa en [arquitectura.md](arquitectura.md#las-tres-capas-donde-vive-la-configuración).
7. **Probar:** inicio de sesión, creación de un ticket (debe salir con su código AT/IN) y envío de correo.

> Para que este runbook sea confiable, se probará una restauración completa en la VM de pruebas y se medirá el tiempo total.
