# Cómo se adaptó GLPI al negocio

GLPI trae decenas de módulos genéricos. El trabajo consistió en dejar solo lo que el área usa y nombrarlo como lo nombra la empresa, sin tocar el código de GLPI ([decisión 005](decisiones/005-personalizacion-fuera-de-glpi.md)).

## Principio de diseño

Antes de configurar algo nuevo, tres preguntas:

1. **¿Lo entiende el cliente o el colaborador?** Se usan las palabras de la empresa: "Ticket" y no "Caso", sus categorías y sus códigos.
2. **¿Sobrevive a una actualización de GLPI?**
3. **¿Choca con algo que ya existe?** Por ejemplo, renombrar la entidad interna rompe la condición de las plantillas de correo.

## Entidades, perfiles y portal

- Una entidad por cliente, una entidad interna y la raíz. Lo que está en una entidad no lo ve otra.
- Cuatro perfiles (ver [arquitectura.md](arquitectura.md#modelo-de-acceso)). Los que solo piden ven un portal simplificado con tarjetas de inicio, no la interfaz completa.
- Los menús de inventario se quitaron: el área no lleva inventario en este sistema.

## Categorías

Siguen los **centros de costo** que el área ya usaba, no las familias de servicios del sitio web: así los indicadores de GLPI calzan con los reportes que ya existían.

## Formulario interno

Reemplazó los correos que las áreas enviaban a Soporte. Un solo formulario con seis tipos de trabajo: cinco asociados a una venta (piden el código de venta) y uno de soporte interno.

Cada tipo arma una cadena de cuatro piezas que deben llamarse igual:

| Pieza | Función |
| --- | --- |
| Opción de "Tipo de trabajo" | Lo que elige el colaborador |
| Preguntas con *Visible si* | Solo aparecen las de ese tipo |
| Destino con *Creado si* | Convierte las respuestas en un ticket; sin condición, duplica tickets |
| Categoría del destino | Clasifica el ticket para los indicadores |

El acceso al formulario se controla por **perfil** en sus Controles de acceso, nunca por personas sueltas.

## Numeración AT/IN

Ver [decisión 002](decisiones/002-numeracion-con-disparador.md) y [glpi/sql/codigo-caso.sql](../glpi/sql/codigo-caso.sql).

```
N.º interno   Título
50            AT-11600 · Código de venta 7281
51            IN-11500 · Soporte interno Impresora
```

## Notificaciones

| Evento | Plantilla | Estado |
| --- | --- | --- |
| Ticket nuevo | Corporativa | Activa |
| Técnico asignado | Asignación | Activa |
| Ticket resuelto | Resuelto | Activa |
| Actualizado / cerrado | — | Desactivadas a propósito ([decisión 006](decisiones/006-aviso-al-resolver.md)) |

- Plantillas HTML con estilos en línea, porque los clientes de correo ignoran las hojas de estilo. Solo imágenes PNG o JPG publicadas (Gmail y Outlook no muestran SVG).
- Una condición en la plantilla distingue los tickets internos ("Ticket Interno N.º").
- **Cada plantilla necesita una traducción predeterminada:** sin ella, GLPI no envía el correo y no muestra error.

## Marca blanca

| Qué se ve | Cómo se logró | Archivo |
| --- | --- | --- |
| Colores y logo | Variables y reglas en el CSS de la entidad raíz; logo en base64 porque GLPI 11 no tiene botón para subirlo y, como documento, los clientes no podían verlo | [personalizacion-marca.css](../glpi/css/personalizacion-marca.css) |
| "Tickets" en vez de "Casos" | El texto original queda en tamaño 0 y el nuevo se escribe con `::after` | mismo CSS, secciones 8 a 10 |
| Sin copyright ni selector de origen en el inicio de sesión | `display: none` en el CSS | mismo CSS |
| Título e ícono de la pestaña | Apache: `Alias` para el ícono y `mod_substitute` para el `<title>` | [personalizacion-marca.conf](../server/apache/personalizacion-marca.conf) |
| Sin "Generado por GLPI" en los correos | Traducción propia | [glpi/locales](../glpi/locales/README.md) |

Para regenerar el logo en base64:

```bash
base64 -w0 logo.png > logo-base64.txt
```
