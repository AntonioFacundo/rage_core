# Plantillas Internas de Juegos

Este directorio contiene plantillas completas de juegos que pueden ser duplicadas para crear nuevos juegos rápidamente.

## Estructura de una Plantilla

Cada plantilla contiene:
- `kernel.gd` - Kernel del juego configurado con sistemas registrados
- `manifest.json` - Metadatos de la plantilla (sistemas, mods, packs incluidos)
- `mod_base.gd` - Mod base del juego
- `pack.json` - Pack de contenido base

## Plantillas Disponibles

1. **arena** - Juego de arena con enemigos que persiguen al jugador
2. **platformer** - Plataformero básico con movimiento, saltos y pickups
3. **roguelike** - Juego roguelike con salas, combate, economía y progresión
4. **topdown** - Juego top-down con combate y movimiento
5. **cards** - Estructura base para juego de cartas

## Uso

```bash
python addons/rage_toolkit/rage.py template:new <game_id> --from <template_name> [--scene]
```

Esto duplicará la plantilla y creará un nuevo juego con todos los sistemas, mods y packs configurados.
