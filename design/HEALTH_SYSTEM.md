# Sistema de Vida Mejorado - Lost Dreams

## Resumen

Sistema de vida completo que sigue los principios de arquitectura de Rage Core **sin modificar el core**:
- **Event-driven**: Usa Event Bus para comunicación desacoplada
- **Determinista**: Compatible con sistema de replay
- **Extensible**: Los mods pueden interceptar y modificar eventos
- **Modular**: Separado en eventos, estado, sistema y API
- **Sin cambios al core**: Todo implementado en la capa del juego (`game/`)

## Componentes

### 1. Eventos (`game/health/events/`)

#### HealthChangedEvent
- Se emite cuando la vida de una entidad cambia
- Payload: `entity_id`, `old_health`, `new_health`, `max_health`, `source`
- Permite a los mods reaccionar a cambios de vida

#### DeathEvent
- Se emite cuando una entidad muere (vida <= 0)
- Payload: `entity_id`, `killer_id`, `cause`
- Útil para sistemas de recompensas, efectos visuales, etc.

#### HealEvent
- Se emite cuando se cura vida
- Payload: `entity_id`, `amount`, `source`, `tags`
- Puede ser interceptado por mods para modificar la cantidad de curación

#### MaxHealthChangedEvent
- Se emite cuando cambia el máximo de vida
- Payload: `entity_id`, `old_max`, `new_max`, `source`
- Útil para actualizar UI, aplicar efectos, etc.

### 2. Estado de Salud (`game/health/health_state.gd`)

Clase independiente que extiende funcionalidad sin modificar `GameState`:
- `_max_health`: Máximo de vida por entidad
- `_health_regen_rate`: Regeneración por segundo
- `_last_death_tick`: Último tick de muerte
- `_regen_accumulator`: Acumulador de precisión para regeneración

Métodos:
- `get_max_health(entity_id)` / `set_max_health(entity_id, value)`
- `get_health_regen_rate(entity_id)` / `set_health_regen_rate(entity_id, rate)`
- `get_last_death_tick(entity_id)` / `set_last_death_tick(entity_id, tick)`
- `get_all_entities_with_health()`: Lista todas las entidades con vida configurada

### 3. HealthSystem (`game/health/health_system.gd`)

Sistema que se ejecuta en `PHASE_GAMEPLAY`:
- **Regeneración**: Procesa regeneración de vida acumulada por segundo
- **Detección de muerte**: Verifica entidades con vida <= 0 y emite `DeathEvent`
- **Eventos**: Emite `HealthChangedEvent` y `HealEvent` cuando corresponde

### 4. HealthManager (`game/health/health_manager.gd`)

Facade que coordina el sistema de salud:
- Se suscribe a eventos de daño para emitir eventos de cambio de vida
- Proporciona métodos de alto nivel para gestionar vida
- Usa `GameAPI` para interactuar con el core sin modificarlo

Métodos principales:
- `set_max_health(entity_id, value, source)`: Configura máximo de vida
- `set_health_regen_rate(entity_id, rate)`: Configura regeneración
- `apply_heal(entity_id, amount, source, tags)`: Cura vida y emite eventos
- `get_max_health(entity_id)` / `get_health_regen_rate(entity_id)`: Consultas

## Uso

### Configurar vida inicial

```gdscript
# En el kernel o sistema de inicialización
var health_mgr = Kernel.get_health_manager()
health_mgr.set_max_health("player", 100, "init")
_api.get_state().set_health("player", 100)
health_mgr.set_health_regen_rate("player", 2.0)  # 2 HP por segundo
```

### Suscribirse a eventos (en mods)

```gdscript
const HealthChangedEvent = preload("res://game/health/events/health_changed_event.gd")
const DeathEvent = preload("res://game/health/events/death_event.gd")
const HealEvent = preload("res://game/health/events/heal_event.gd")

func on_load(api: GameAPI) -> void:
    # Reaccionar a cambios de vida
    api.subscribe("game.health.changed", _on_health_changed)
    
    # Reaccionar a muertes
    api.subscribe("game.health.death", _on_death)
    
    # Interceptar curación (modificar cantidad)
    api.subscribe("game.health.heal", _on_heal, 0, true)  # intercept mode

func _on_health_changed(ev: HealthChangedEvent) -> void:
    if ev.get_entity_id() == "player":
        print("Vida: ", ev.get_new_health(), "/", ev.get_max_health())

func _on_death(ev: DeathEvent) -> void:
    if ev.get_entity_id() == "player":
        print("¡El jugador ha muerto!")

func _on_heal(ev: HealEvent) -> void:
    # Duplicar toda curación
    ev.set_amount(ev.get_amount() * 2)
```

### Curar vida

```gdscript
# Desde cualquier sistema o mod
var health_mgr = Kernel.get_health_manager()
health_mgr.apply_heal("player", 25, "potion", ["healing", "item"])
```

## Integración con el Pipeline

El `HealthSystem` debe registrarse en el kernel:

```gdscript
_health_system = HealthSystem.new()
_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 15, _health_system)
```

**Prioridad recomendada**: 15 (después de CombatSystem que es 20, antes de otros sistemas)

## Características

✅ **Determinista**: Usa acumuladores de precisión para regeneración  
✅ **Event-driven**: Todo cambio emite eventos  
✅ **Extensible**: Mods pueden interceptar y modificar  
✅ **Seguro**: Validación de IDs y valores  
✅ **Compatible con replay**: Estado exportado en `export_canonical()`  

## Mejoras Futuras

- Escudos/armadura temporales
- Overheal (vida temporal sobre el máximo)
- Diferentes tipos de regeneración (combate vs fuera de combate)
- Integración con sistema de tick para `last_death_tick` más preciso
- Buffs/debuffs que afecten regeneración
