# 🎮 Ejemplo Práctico: Crear un Roguelike en 5 Minutos

## Concepto del Juego

**"Fragment Forge"** - Un roguelike donde:
- Derrotas enemigos y obtienes "Fragmentos de Sistema"
- Combinas fragmentos para crear sistemas nuevos
- Cada sistema agrega mecánicas al juego
- La metaprogramación genera los sistemas automáticamente

---

## 🚀 Paso 1: Generar el Juego Base (30 segundos)

```gdscript
# Ejecuta esto UNA VEZ desde el editor
extends EditorScript

func _run() -> void:
	var creator = load("res://game/tools/examples/create_roguelike_game.gd").new()
	creator.create_roguelike()
```

**Resultado automático:**
```
✅ 6 sistemas creados
✅ 18 eventos creados
✅ Archivos listos en res://game/systems/roguelike/
```

---

## 🎯 Paso 2: Implementar un Sistema (Ejemplo: Combat)

El archivo ya está generado, solo implementas la lógica:

```gdscript
# res://game/systems/roguelike/combat_system.gd (ya generado)
class_name CombatSystem
extends SimulationStep

const DamageDealtEvent = preload("res://game/events/damage_dealt_event.gd")
const EnemyDefeatedEvent = preload("res://game/events/enemy_defeated_event.gd")
const PlayerHitEvent = preload("res://game/events/player_hit_event.gd")

func run(context: SimulationContext, delta: float) -> void:
	# Tu lógica aquí - el boilerplate ya está hecho
	_process_combat(context, delta)

func _process_combat(context: SimulationContext, delta: float) -> void:
	# Implementar combate
	pass
```

---

## 🧪 Paso 3: Probar Rápidamente (Sin correr el juego)

```gdscript
# test_combat.gd
var combat = CombatSystem.new()
var results = SimulationRunner.quick_test_system(
    combat,
    {"health": [["player", 100], ["enemy", 50]]},
    60  # 1 segundo
)

print("HP final player: ", results.final_state.health[0][1])
print("HP final enemy: ", results.final_state.health[1][1])
```

---

## 🎮 Ejemplo Completo: Sistema de Veneno

### 1. Generar (1 línea)
```gdscript
CodeGenerator.generate_system_complete("Poison", "res://game/systems", "phase.gameplay", 25, ["PoisonApplied", "PoisonTick"])
```

### 2. Implementar (solo la lógica)
```gdscript
# El archivo ya tiene la estructura, solo agregas lógica
func run(context: SimulationContext, delta: float) -> void:
	for entity_id in _poisoned_entities:
		_apply_poison_damage(context, entity_id, delta)
```

### 3. Probar
```gdscript
var poison = PoisonSystem.new()
var results = SimulationRunner.quick_test_system(poison, {}, 100)
```

---

## 📊 Comparación: Con vs Sin Metaprogramación

### Sin Metaprogramación (Manual)
1. Crear archivo `poison_system.gd` (2 min)
2. Escribir class_name, extends, consts (3 min)
3. Crear `poison_applied_event.gd` (2 min)
4. Crear `poison_tick_event.gd` (2 min)
5. Registrar en kernel (2 min)
6. Probar (5 min)

**Total: ~16 minutos por sistema**

### Con Metaprogramación
1. `CodeGenerator.generate_system_complete(...)` (5 seg)
2. Implementar lógica (5 min)
3. Probar con `SimulationRunner` (1 min)

**Total: ~6 minutos por sistema**

**Ahorro: 60% del tiempo**

---

## 🎯 Caso de Uso Real: Agregar 10 Sistemas

### Sin Metaprogramación
- 10 sistemas × 16 min = **160 minutos (2.6 horas)**
- Mucho código repetitivo
- Fácil cometer errores
- Difícil mantener consistencia

### Con Metaprogramación
- Generar todos: **1 minuto**
- Implementar lógica: **50 minutos** (5 min × 10)
- Probar: **10 minutos**

**Total: ~61 minutos (1 hora)**

**Ahorro: 99 minutos (62% más rápido)**

---

## 🚀 Flujo de Trabajo Real

### Día 1: Setup (5 minutos)
```gdscript
# Crear todos los sistemas base
creator.create_roguelike()
```

### Día 2-5: Implementar Lógica
- Abres cada archivo generado
- Implementas solo la lógica de negocio
- Pruebas con `SimulationRunner`

### Día 6: Agregar Sistema Nuevo (5 minutos)
```gdscript
# Necesitas un sistema de "Bleeding"?
CodeGenerator.generate_and_register_system("Bleeding")
# Implementas lógica
# ¡Listo!
```

---

## 💡 Ventajas Clave

1. **Velocidad**: Crea sistemas en segundos
2. **Consistencia**: Mismo formato siempre
3. **Sin errores**: No olvidas registrar sistemas
4. **Escalable**: Agrega 100 sistemas fácilmente
5. **Mantenible**: Cambias template, regeneras todo

---

## 🎮 Resultado Final

Un juego completo con:
- ✅ 6+ sistemas funcionando
- ✅ 18+ eventos definidos
- ✅ Todo probado y funcionando
- ✅ Fácil agregar más sistemas

**Tiempo total**: De semanas a días para un prototipo completo.
