# 003 — Español (México) y traducción propia en `files/_locales`

**Estado:** aceptada e implementada.

## Contexto
La interfaz y los correos debían verse en español y sin rastros del software de fábrica (por ejemplo, "Generado automáticamente por GLPI" al pie de los correos).

## Decisión
- Idioma predeterminado **Español (México)**: su traducción estaba prácticamente completa; la de Chile, alrededor de un tercio.
- Los textos que no se pueden cambiar en pantalla se reemplazan con una **traducción propia** en `files/_locales/core/es_MX.php`.
- Antes de iniciar sesión, GLPI usa el idioma del navegador; por eso las otras variantes de español apuntan al mismo archivo con enlaces simbólicos. Ver [glpi/locales/README.md](../../glpi/locales/README.md).

## Alternativas
| Opción | Por qué no |
| --- | --- |
| Editar los archivos `.po` de GLPI | Se sobrescriben en cada actualización |
| Español (Chile) | Traducción incompleta: menús a medio traducir |

## Consecuencias
- Lo que vive en `files/` sobrevive a las actualizaciones y viaja con el respaldo.
- Ningún usuario debe cambiar su idioma: en otra variante cambian los nombres de los menús y vuelve el texto de fábrica.
- Después de cada cambio: `cache:clear` y prueba en una ventana de incógnito.
