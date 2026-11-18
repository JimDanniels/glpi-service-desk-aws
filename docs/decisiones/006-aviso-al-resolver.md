# 006 — El aviso final se envía al resolver, no al cerrar

**Estado:** aceptada.

## Contexto
GLPI distingue *Resuelto* (el técnico dio la solución) de *Cerrado* (etapa final). Con todas las notificaciones activas, el solicitante recibía correos repetidos.

## Decisión
Solo tres correos: **nuevo**, **asignado** y **resuelto**. "Actualizado" y "Cerrado" quedan desactivados a propósito.

## Consecuencias
- La solución se escribe para el solicitante, porque es el texto que le llega por correo.
- Cuando el caso se deriva a otra área, el ticket se resuelve explicando a dónde pasó; si no, el solicitante cree que se lo cerraron sin ayudarlo.
