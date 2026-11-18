# 008 — Todo cambio se prueba primero en una VM

**Estado:** aceptada.

## Contexto
El sistema lo usan clientes reales, y varios errores de GLPI no muestran aviso (por ejemplo, una plantilla de correo sin traducción predeterminada simplemente no envía).

## Decisión
GLPI se montó primero en una VM con Ubuntu Server en VirtualBox. Allí se probó toda la configuración antes de llevarla a AWS, y la VM quedó como ambiente de pruebas permanente: perfiles, formularios y plantillas se prueban ahí antes de producción.

## Consecuencias
- La VM también es la máquina del respaldo *pull*; no se apaga en horario de oficina.
- Al restaurar un respaldo de producción en la VM hay que desactivar antes su correo: trae la cola de notificaciones y las cuentas reales.
