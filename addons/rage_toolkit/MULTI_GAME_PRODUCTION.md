# Producción de Múltiples Juegos

Esta guía explica cómo usar Rage Core y Rage Toolkit para producir múltiples juegos rápidamente reutilizando el framework estable y las herramientas.

## Principios de Organización

- **Framework congelado**: `addons/rage_core/` se mantiene estable y no se modifica
- **Código del juego**: Cada juego tiene su código en `game/` (kernel + sistemas propios)
- **Mods**: Extensiones por API en `mods/`
- **Contenido**: Variaciones data-driven en `data_packs/`
- **Kernel único**: `game/game_kernel.gd` es el único composition root

## Pipeline Recomendado (Repetible por Juego)

### A. Scaffold Inicial (Minutos)

#### Opción 1: Usando Plantillas Internas (Recomendado)

```bash
python addons/rage_toolkit/rage.py template:new <game_id> --from <template> --scene
```

Plantillas disponibles:
- `arena` - Juego de arena con enemigos que persiguen
- `platformer` - Plataformero con movimiento, saltos y pickups
- `roguelike` - Roguelike completo con salas, combate, economía y progresión
- `topdown` - Juego top-down con combate y movimiento
- `cards` - Estructura base para juegos de cartas

#### Opción 2: Usando Dock de Godot

1. Activar el plugin **Rage Toolkit**
2. Abrir el dock **Rage Core Scaffold**
3. Seleccionar una plantilla interna en "Game Template"
4. Ingresar el ID del juego y hacer clic en "Create Game"

#### Opción 3: Scaffold Manual

```bash
python addons/rage_toolkit/rage.py project:init --scene
```

### B. Construir Biblioteca de Mecánicas Reusables (Horas → Días)

Estandarizar sistemas comunes por familia:
- Movimiento/combate/loot/economía/progresión/quests/etc.

Para acelerar, usar los generadores:

```bash
# Generar sistema completo con eventos
python addons/rage_toolkit/rage.py system:complete Combat --events DamageDealt EnemyDefeated

# Generar sistema individual
python addons/rage_toolkit/rage.py system:new Movement --phase phase.movement --priority 50

# Generar evento
python addons/rage_toolkit/rage.py event:new ItemCollected --event-id game.inventory.item_collected

# Generar comando
python addons/rage_toolkit/rage.py command:new UseItem --command-id cmd.inventory.use_item
```

Herramientas equivalentes en GDScript dentro de `addons/rage_toolkit/dev_tools/`.

### C. Variación por Contenido (Minutos → Horas)

Usar `data_packs/*.json` para crear variantes de juego sin tocar lógica:

```bash
# Crear nuevo pack de contenido
python addons/rage_toolkit/rage.py pack:new my_variant

# Agregar contenido al pack
python addons/rage_toolkit/rage.py pickup:new power_up --mod my_game
python addons/rage_toolkit/rage.py enemy:new boss --mod my_game --ai chase
```

Encapsular "reglas" nuevas como mods, y dejar que el contenido las active por ids/tags.

### D. Iteración Rápida con Simulación Determinista (Minutos)

Antes de abrir la escena/UI, validar mecánicas con simulación:

```gdscript
# Usar HeadlessSimulator y SimulationRunner
var results = SimulationRunner.quick_test_system(my_system, {}, 100)
```

Ver guía: `design/RAPID_DEV_GUIDE.md`

Usar replay determinista para regresión (ver `addons/rage_core/docs/REPLAY.md`).

## Estrategia para "Muchos Juegos"

### Plantillas Internas

Se han creado 3-5 plantillas internas completas en `addons/rage_toolkit/templates/`:

1. **arena** - Juego de arena
   - Sistemas: movement_2d, combat, health, pickup, ai
   - Contenido: enemy_small (chase)

2. **platformer** - Plataformero básico
   - Sistemas: movement_2d, combat, health, pickup, surface, ladder
   - Contenido: pickup_speed

3. **roguelike** - Roguelike completo
   - Sistemas: movement_2d, combat, health, pickup, room_combat, room_economy, shop_offer, shop_resolve, ability_award, parkour_gate, boss_stage, boss_reward, run_end, level_selection
   - Contenido: Configurable

4. **topdown** - Top-down
   - Sistemas: movement_2d, combat, health, pickup, ai
   - Contenido: enemy_small (patrol), pickup_health

5. **cards** - Estructura base para cartas
   - Sistemas: Base (extensible)
   - Contenido: Configurable

### Flujo de Creación de Nuevo Juego

Para cada nuevo juego:

1. **Duplicar una plantilla**:
   ```bash
   python addons/rage_toolkit/rage.py template:new my_new_game --from platformer --scene
   ```

2. **Personalizar packs y mods**:
   - Modificar `data_packs/my_new_game.json` para cambiar contenido
   - Agregar mods diferenciadores en `mods/my_new_game/`

3. **Ajustar kernel si es necesario**:
   - Editar `game/game_kernel.gd` para registrar sistemas adicionales o cambiar configuración

4. **Iterar rápidamente**:
   - Usar simulación headless para probar mecánicas
   - Usar generadores para crear nuevos sistemas
   - Usar packs para variar contenido sin tocar código

### Mantener Compatibilidad

- Rage Toolkit declara dependencia de Rage Core (ya reflejado en `addons/rage_toolkit/plugin.cfg`)
- Framework `addons/rage_core/` se mantiene congelado
- Cada juego es independiente en `game/`, `mods/`, y `data_packs/`

## Empaquetado y Distribución

### Releases Internos

Para releases internos del equipo:

```powershell
.\create_release_zips.ps1
```

Esto genera:
- `rage_core_vX.Y.Z.zip`
- `rage_toolkit_vX.Y.Z.zip`

Mantener `CHANGELOG.md` y tags `vX.Y.Z` actualizados.

### Publicación en Asset Library

Publicar Rage Core/Toolkit en Asset Library para poder "instalar" en cualquier juego desde Godot.

Ver guías:
- `addons/rage_core/PUBLISHING.md`
- `addons/rage_toolkit/PUBLISHING.md`

## Ejemplo Completo: Crear un Nuevo Juego

```bash
# 1. Crear juego desde plantilla
python addons/rage_toolkit/rage.py template:new space_shooter --from topdown --scene

# 2. Agregar contenido específico
python addons/rage_toolkit/rage.py pickup:new shield --mod space_shooter
python addons/rage_toolkit/rage.py enemy:new asteroid --mod space_shooter --ai idle

# 3. Generar sistema personalizado
python addons/rage_toolkit/rage.py system:complete WeaponSystem --events WeaponFired ProjectileHit

# 4. Abrir en Godot y configurar escenas
# 5. Probar con simulación headless
# 6. Iterar rápidamente
```

## Ventajas del Sistema

- **Rápido**: Crear un nuevo juego en minutos desde una plantilla
- **Reutilizable**: Framework estable, sistemas compartidos
- **Escalable**: Fácil mantener múltiples juegos
- **Determinista**: Simulación y replay para testing
- **Data-driven**: Variar contenido sin tocar código
- **Modular**: Mods y packs independientes
