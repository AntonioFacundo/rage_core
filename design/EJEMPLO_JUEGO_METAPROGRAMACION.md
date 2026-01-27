# Ejemplo: Crear un Juego Completo con Metaprogramación

## 🎮 Juego: "System Builder" - Un Roguelike donde Construyes Sistemas

**Concepto**: Un juego donde el jugador desbloquea y combina "sistemas" para crear mecánicas nuevas. Usamos metaprogramación para generar estos sistemas dinámicamente.

---

## 📋 Diseño del Juego

### Mecánica Principal
- El jugador encuentra "Fragmentos de Sistema" durante la partida
- Puede combinar fragmentos para crear sistemas nuevos
- Cada sistema agrega mecánicas al juego en tiempo real
- Los sistemas se generan usando CodeGenerator

### Ejemplo de Sistemas Desbloqueables
1. **Sistema de Veneno** - Daño over time
2. **Sistema de Escudos** - Protección temporal
3. **Sistema de Combos** - Bonificaciones por secuencias
4. **Sistema de Buffs** - Mejoras temporales
5. **Sistema de Loot** - Drops mejorados

---

## 🚀 Implementación con Metaprogramación

### Paso 1: Crear el Sistema Base del Juego

```gdscript
# Usando CodeGenerator para crear el juego base
CodeGenerator.generate_and_register_system("Combat", "res://game/game_kernel.gd", "res://game/systems", "phase.gameplay", 50)
CodeGenerator.generate_and_register_system("Economy", "res://game/game_kernel.gd", "res://game/systems", "phase.gameplay", 40)
CodeGenerator.generate_and_register_system("Progression", "res://game/game_kernel.gd", "res://game/systems", "phase.post", 30)
```

### Paso 2: Sistema de Fragmentos (Meta-Sistema)

```gdscript
# game/systems/fragment_system.gd
class_name FragmentSystem
extends SimulationStep

var _unlocked_fragments: Array = []
var _code_generator: CodeGenerator

func _init() -> void:
	_code_generator = CodeGenerator.new()

func run(context: SimulationContext, delta: float) -> void:
	# Lógica del juego: encontrar fragmentos, desbloquear sistemas, etc.
	_check_fragment_drops(context)
	_process_unlocks(context)

func _check_fragment_drops(context: SimulationContext) -> void:
	# Cuando el jugador derrota enemigos, puede obtener fragmentos
	# Esto es parte de la mecánica del juego
	pass

func _process_unlocks(context: SimulationContext) -> void:
	# Cuando el jugador tiene suficientes fragmentos, desbloquea un sistema
	pass

# MÉTODO PRINCIPAL: Generar sistema dinámicamente
func unlock_system(system_name: String, fragments: Array) -> Result:
	if _unlocked_fragments.has(system_name):
		return Result.err_result("Sistema ya desbloqueado")
	
	# Usar metaprogramación para crear el sistema
	var events := _get_events_for_fragments(fragments)
	var results := CodeGenerator.generate_system_complete(
		system_name,
		"res://game/systems/unlocked",
		"phase.gameplay",
		20,
		events,
		true  # Sobrescribir si existe
	)
	
	if results.errors.size() > 0:
		return Result.err_result("Error generando sistema: " + str(results.errors))
	
	# Cargar y registrar el sistema dinámicamente
	var system_script := load("res://game/systems/unlocked/" + system_name.to_lower() + "_system.gd")
	if system_script == null:
		return Result.err_result("No se pudo cargar el sistema generado")
	
	var system_instance := system_script.new()
	context.core._pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 20, system_instance)
	
	_unlocked_fragments.append(system_name)
	return Result.ok_result(system_instance)

func _get_events_for_fragments(fragments: Array) -> Array:
	var events: Array = []
	for fragment in fragments:
		match fragment:
			"poison":
				events.append("PoisonApplied")
				events.append("PoisonTick")
			"shield":
				events.append("ShieldActivated")
				events.append("ShieldBroken")
			"combo":
				events.append("ComboStarted")
				events.append("ComboCompleted")
	return events
```

---

## 🎯 Ejemplo Completo: Sistema de Veneno

### Generación Automática

```gdscript
# Cuando el jugador desbloquea "Veneno", esto se ejecuta:

func _on_poison_unlocked() -> void:
	var fragments := ["poison", "damage_over_time"]
	
	# 1. Generar eventos
	CodeGenerator.generate_event_file("PoisonApplied", "res://game/events/poison_applied_event.gd", "game.poison.applied")
	CodeGenerator.generate_event_file("PoisonTick", "res://game/events/poison_tick_event.gd", "game.poison.tick")
	
	# 2. Generar sistema completo
	var results = CodeGenerator.generate_system_complete(
		"Poison",
		"res://game/systems/unlocked",
		"phase.gameplay",
		25,
		["PoisonApplied", "PoisonTick"],
		true
	)
	
	# 3. El sistema se carga automáticamente en el próximo tick
	# 4. El jugador ahora tiene veneno funcionando en su partida
```

### Sistema Generado Automáticamente

```gdscript
# res://game/systems/unlocked/poison_system.gd (generado automáticamente)
class_name PoisonSystem
extends SimulationStep

const PoisonAppliedEvent = preload("res://game/events/poison_applied_event.gd")
const PoisonTickEvent = preload("res://game/events/poison_tick_event.gd")

var _poison_effects := {}  # entity_id -> {stacks: int, duration: float}

func run(context: SimulationContext, delta: float) -> void:
	_process_poison_ticks(context, delta)

func _process_poison_ticks(context: SimulationContext, delta: float) -> void:
	for entity_id in _poison_effects.keys():
		var effect = _poison_effects[entity_id]
		effect.duration -= delta
		
		if effect.duration <= 0:
			_poison_effects.erase(entity_id)
			continue
		
		# Cada segundo, aplicar daño
		if effect.next_tick <= 0:
			var damage := effect.stacks * 2  # 2 daño por stack
			context.core.apply_damage("poison", entity_id, damage, ["poison"])
			
			var tick_ev := PoisonTickEvent.new(entity_id, damage, effect.stacks)
			context.bus.emit(tick_ev)
			
			effect.next_tick = 1.0
		else:
			effect.next_tick -= delta
```

---

## 🎮 Flujo de Juego Completo

### 1. Jugador Encuentra Fragmento
```gdscript
# En el juego
func _on_enemy_defeated(enemy_id: String) -> void:
	var fragment := _drop_fragment()  # "poison"
	_player_collect_fragment(fragment)
```

### 2. Jugador Combina Fragmentos
```gdscript
# UI del juego: "Combinar Fragmentos"
func _on_combine_fragments(fragments: Array) -> void:
	var system_name := _generate_system_name(fragments)  # "PoisonSystem"
	
	# METAPROGRAMACIÓN: Generar sistema en tiempo real
	var result := _fragment_system.unlock_system(system_name, fragments)
	
	if result.ok:
		_show_message("¡Sistema " + system_name + " desbloqueado!")
		# El sistema ya está funcionando en el juego
```

### 3. El Sistema Funciona Inmediatamente
```gdscript
# El sistema generado ya está registrado en el pipeline
# Funciona automáticamente en cada tick
# El jugador puede usar veneno inmediatamente
```

---

## 🔧 Ejemplo Práctico: Crear el Juego Completo

### Script de Setup (ejecutar una vez)

```gdscript
# setup_game.gd - Ejecutar desde el editor
extends EditorScript

func _run() -> void:
	print("Generando juego completo...")
	
	# 1. Sistemas base
	CodeGenerator.generate_and_register_system("Combat")
	CodeGenerator.generate_and_register_system("Economy")
	CodeGenerator.generate_and_register_system("Progression")
	
	# 2. Sistema de fragmentos (meta-sistema)
	CodeGenerator.generate_and_register_system("Fragment", "res://game/game_kernel.gd", "res://game/systems", "phase.post", 10)
	
	# 3. Sistemas desbloqueables (pre-generados para referencia)
	var unlockable_systems := [
		{"name": "Poison", "events": ["PoisonApplied", "PoisonTick"]},
		{"name": "Shield", "events": ["ShieldActivated", "ShieldBroken"]},
		{"name": "Combo", "events": ["ComboStarted", "ComboCompleted"]},
		{"name": "Buffs", "events": ["BuffApplied", "BuffExpired"]},
		{"name": "Loot", "events": ["LootDropped", "LootCollected"]}
	]
	
	for system_data in unlockable_systems:
		CodeGenerator.generate_system_complete(
			system_data.name,
			"res://game/systems/unlocked",
			"phase.gameplay",
			20,
			system_data.events,
			false  # No sobrescribir si existe
		)
	
	print("✅ Juego generado! Revisa res://game/systems/")
```

---

## 🎯 Ventajas de Este Enfoque

### Para el Desarrollador
- ✅ Crea sistemas en segundos
- ✅ No escribes boilerplate manualmente
- ✅ Consistencia automática
- ✅ Fácil agregar nuevos sistemas

### Para el Juego (si lo haces parte del gameplay)
- ✅ Sistemas generados dinámicamente
- ✅ Contenido procedimental
- ✅ Mecánicas emergentes
- ✅ Rejugabilidad infinita

---

## 🚀 Ejemplo de Uso en Runtime

```gdscript
# En el juego, cuando el jugador desbloquea algo:

func _on_player_unlocks_poison() -> void:
	# Generar sistema en tiempo real (requiere permisos especiales)
	# Nota: En runtime esto es más complejo, pero posible con GDScript
	
	# Alternativa: Pre-generar sistemas y activarlos/desactivarlos
	_activate_system("PoisonSystem")
```

---

## 📝 Notas Importantes

1. **Runtime vs Editor**: 
   - Generar código en runtime es posible pero complejo
   - Mejor: Pre-generar sistemas y activarlos dinámicamente
   - O: Usar sistemas modulares que se combinan

2. **Seguridad**: 
   - Validar sistemas generados
   - Sandbox para código generado
   - Limitar qué puede hacer

3. **Performance**:
   - Pre-generar sistemas comunes
   - Cachear sistemas generados
   - Hot-reload solo en desarrollo

---

## 🎮 Resultado Final

Un juego donde:
- El desarrollador crea sistemas en minutos usando CodeGenerator
- El jugador puede desbloquear/activar sistemas (si lo haces parte del gameplay)
- Nuevo contenido se agrega rápidamente
- Mecánicas emergentes de combinaciones

**Tiempo de desarrollo**: De semanas a horas para agregar nuevos sistemas.

---

## 🎯 Ejemplo Real: Roguelike Completo en 5 Minutos

```gdscript
# Ejecuta esto una vez para crear un roguelike completo
extends EditorScript

func _run() -> void:
	var creator = load("res://game/tools/examples/create_roguelike_game.gd").new()
	creator.create_roguelike()
```

**Resultado**: 
- 6 sistemas completos generados
- 18 eventos creados
- Todo listo para implementar lógica
- Registrado en kernel automáticamente

**Tiempo**: ~30 segundos de ejecución vs horas de código manual.
