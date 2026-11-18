# 004 — Ocultar menús quitando permisos, nunca con CSS

**Estado:** aceptada.

## Contexto
A técnicos y colaboradores había que quitarles menús que no usan (por ejemplo, inventario).

## Decisión
Un menú se oculta **quitando el permiso en el perfil**. El CSS solo se usa para la apariencia (colores, logo, textos visibles).

## Por qué
Con CSS el menú desaparece de la vista, pero la página sigue disponible para quien escriba la dirección. Quitar el permiso lo bloquea de verdad, no borra datos y se revierte marcando la casilla otra vez.
