# 005 — Toda personalización fuera del código de GLPI

**Estado:** aceptada.

## Contexto
GLPI se actualiza reemplazando sus archivos. Cualquier cambio hecho dentro de ellos se pierde.

## Decisión
Cada ajuste va en una capa que sobrevive a la actualización:

| Ajuste | Dónde vive |
| --- | --- |
| Colores, logo, "Tickets" en vez de "Casos", ocultar copyright | CSS de la entidad raíz (base de datos) |
| Textos fijos de la interfaz y los correos | `files/_locales` |
| Ícono y título de la pestaña | Apache: `Alias` + `mod_substitute` |
| Numeración AT/IN | Tabla y disparador en la base de datos |
| Ajustes de Fail2ban | `jail.local` (no `jail.conf`) |

## Consecuencias
- Hay una lista fija de revisión después de cada actualización: instalador, disparador, las secciones del CSS que dependen del HTML de GLPI, caché y correos.
- Los cambios de texto por CSS son solo visuales (el texto original queda en tamaño 0 y el nuevo se escribe con `::after`), así que son los primeros en romperse si GLPI cambia su HTML.
