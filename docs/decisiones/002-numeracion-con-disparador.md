# 002 — Numeración AT/IN con un disparador en la base de datos

**Estado:** aceptada e implementada.

## Contexto
La empresa necesitaba distinguir los casos de clientes (AT) de los internos (IN), cada uno con su propia numeración y un número inicial definido. GLPI tiene un solo contador de tickets, y su columna ID solo admite números.

## Decisión
Una tabla `contadores_caso` (último número por prefijo) y un disparador `BEFORE INSERT` en `glpi_tickets` que, según la entidad del ticket, toma el siguiente número de la serie y lo escribe al inicio del título: `AT-11600 · título`. Ver [glpi/sql/codigo-caso.sql](../../glpi/sql/codigo-caso.sql).

## Alternativas
| Opción | Por qué no |
| --- | --- |
| Plugin *Fields* (campo propio "N.º de caso") | En GLPI 11 había reportes de problemas, y no estaba confirmado que sus campos funcionaran en las plantillas de correo |
| Usar el ID de GLPI | Un solo contador para todo y sin letras |
| Que el técnico escriba el código a mano | Errores y números repetidos |

## Consecuencias
- Al estar en el título, el código aparece solo en la lista, el buscador, las exportaciones y los correos.
- `SELECT … FOR UPDATE` evita que dos tickets simultáneos reciban el mismo número.
- **Antes de actualizar GLPI** se quita el disparador y se vuelve a crear después (solo el disparador, no la tabla), porque no está confirmado que la actualización tolere un disparador ajeno.
- Borrar un ticket no devuelve su número: después de pruebas, el contador se retrocede a mano.
- `mysqldump --triggers` incluye el disparador en cada respaldo.
