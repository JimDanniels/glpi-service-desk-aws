# Traducción propia

GLPI permite reemplazar frases de su traducción oficial con un archivo propio en `files/_locales`, sin tocar el código. Se usó para quitar textos de fábrica, por ejemplo la frase "Generado automáticamente por GLPI" del pie de los correos, y para unificar el trato en la pantalla de recuperación de contraseña.

```
/var/www/glpi/files/_locales/core/es_MX.php
```

## Por qué los enlaces simbólicos

Antes de iniciar sesión, GLPI usa el idioma que informa el navegador, no el configurado. Si el navegador está en otra variante de español, el archivo propio no se aplica. Para mantener un solo archivo, las demás variantes apuntan a él:

```bash
cd /var/www/glpi/files/_locales/core
for v in es_419 es_AR es_CL es_CO es_EC es_ES es_VE; do
  sudo -u www-data ln -s es_MX.php "$v.php"
done
cd /var/www/glpi && sudo -u www-data php bin/console cache:clear
```

**Regla:** se edita solo `es_MX.php`. Después de cada cambio, `cache:clear` y prueba en una ventana de incógnito nueva. El archivo vive en `files/`, así que sobrevive a las actualizaciones y viaja con el respaldo.
