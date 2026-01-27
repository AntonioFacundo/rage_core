# Tutorial (ES): Armar un sistema con Rage Core + Toolkit

Objetivo: saber los pasos desde el scaffold/CLI hasta el codigo que debes editar para crear o extender sistemas como el flujo actual.

> Nota: aqui solo se describe el flujo. No se agregan sistemas nuevos desde el CLI.

## 1) Crear estructura base (CLI)
Un dev ejecutaria estos comandos en la raiz del repo:

```bash
python rage.py project:init --scene
```

Esto crea (si no existen):
- `res://game/` (codigo del juego)
- `res://design/` (docs)
- `res://mods/` y `res://data_packs/`
- `res://game/game_kernel.gd` (kernel del juego)

## 2) Alternativa: Scaffold Dock (UI de Godot)
1. Activar el plugin **Rage Toolkit**.
2. Abrir el dock **Rage Core Scaffold**.
3. Usar **Project Init** para generar estructura base.

## 3) Mod vs Data Pack (simple)

- **Mod (codigo)**: ejecuta logica. Vive en `res://mods/<id>/mod_*.gd` y usa `on_load(api)` para registrar comportamiento.
- **Data Pack (datos)**: define contenido. Vive en `res://data_packs/<id>.json` y agrega `content.*` al registro.

Regla rapida:
- Si quieres **comportamiento**, haz un **mod**.
- Si quieres **datos**, haz un **data pack**.

Puedes tener:
- Mod sin pack (solo logica).
- Data pack sin mod (solo datos).
- Ambos si necesitas logica + datos.

## 4) Assets dentro de un mod
Un mod puede traer assets propios. Convencion recomendada:

- `res://mods/<mod_id>/assets/`
- `res://mods/<mod_id>/scenes/`

Ejemplos de rutas:
- `res://mods/mi_mod/assets/audio/tema.ogg`
- `res://mods/mi_mod/assets/sprites/enemy.png`
- `res://mods/mi_mod/scenes/boss.tscn`

El pack JSON o el codigo del mod solo referencian esas rutas.

## 5) Crear un mod y su data pack (CLI)
Un dev ejecutaria:

```bash
python rage.py modpack:new base --scene
```

Esto crea:
- `res://mods/base/mod_base.gd`
- `res://data_packs/base.json`
- (opcional) una escena base

## 6) Donde editar para agregar logica
Todo el codigo del juego vive en `res://game/`.

Piezas principales:
- `game/game_kernel.gd`
  - Es el punto de composicion. Aqui registras sistemas en el pipeline.
  - Orden y fases deterministas.
- `game/run_state.gd`
  - Estado del run. Todo lo determinista vive aqui.
- `game/<sistema>/*_system.gd`
  - Sistemas deterministas (`SimulationStep`).
  - Mutan el `RunState`.

## 7) Donde editar contenido data-driven
- `res://data_packs/*.json`
  - Contenido como rooms, waves, enemies, etc.
  - Puedes agregar ids, tags, tiers y pesos.

## 8) Flujo recomendado para crear un sistema nuevo
1) Define el estado en `game/run_state.gd`.
2) Crea el sistema en `game/<tu_sistema>/` (clase `SimulationStep`).
3) Registra el sistema en `game/game_kernel.gd` con phase/priority.
4) (Opcional) agrega contenido en `data_packs/*.json`.

## 9) Checklist rapido
- El sistema no usa Godot APIs directas (solo core/game types).
- El orden es determinista.
- Logs son estables.
- El kernel sigue siendo el unico composition root.

