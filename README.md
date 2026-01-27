# Rage Core & Rage Toolkit

Framework de desarrollo de juegos en capas para Godot 4.x con soporte para mods, content packs, y sistema de replay determinista.

## Addons

Este repositorio contiene dos addons para Godot:

### Rage Core
Framework principal con arquitectura en capas, sistema de mods, y replay determinista.

Ubicacion: addons/rage_core/

Documentacion: Ver addons/rage_core/README.md

### Rage Toolkit
Herramientas de editor y CLI para Rage Core. Incluye UI de scaffolding y herramientas de metaprogramacion.

Ubicacion: addons/rage_toolkit/

Documentacion: Ver addons/rage_toolkit/README.md

IMPORTANTE: Rage Toolkit requiere Rage Core instalado primero.

## Instalacion

### Desde Asset Library (Recomendado)
1. Instalar Rage Core desde Asset Library
2. Instalar Rage Toolkit desde Asset Library
3. Habilitar ambos plugins en Project Settings -> Plugins

### Manual
1. Copiar addons/rage_core/ a tu proyecto
2. Copiar addons/rage_toolkit/ a tu proyecto (opcional)
3. Habilitar plugins en Project Settings -> Plugins

## Documentacion

- Rage Core: addons/rage_core/README.md
- Rage Toolkit: addons/rage_toolkit/README.md
- Tutoriales: addons/rage_toolkit/TUTORIAL*.md
- CLI: addons/rage_toolkit/CLI.md

## Uso Rapido

1. Habilitar Rage Core en Project Settings -> Plugins
2. Crear res://game/game_kernel.gd que extienda GameKernel
3. Registrar sistemas en el pipeline
4. Jugar!

Ver los READMEs de cada addon para mas detalles.

## Licencia

MIT License - Ver addons/rage_core/LICENSE y addons/rage_toolkit/LICENSE

## Publicacion

Ambos addons estan preparados para publicarse en el Asset Library de Godot.

Ver:
- addons/rage_core/PUBLISHING.md
- addons/rage_toolkit/PUBLISHING.md
