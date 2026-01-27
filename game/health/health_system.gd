# Game: Health system using Rage Core APIs. No core modifications.
class_name HealthSystem
extends SimulationStep

const HealthChangedEventScript := preload("res://game/health/events/health_changed_event.gd")
const DeathEventScript := preload("res://game/health/events/death_event.gd")
const HealEventScript := preload("res://game/health/events/heal_event.gd")

var _health_state: HealthState

func _init() -> void:
	_health_state = HealthState.new()

func run(context: SimulationContext, delta: float) -> void:
	_process_regeneration(context, delta)
	_check_deaths(context)
	_listen_to_damage_events(context)

func _process_regeneration(context: SimulationContext, delta: float) -> void:
	var entity_ids: Array = _health_state.get_all_entities_with_health()
	for entity_id in entity_ids:
		var regen_rate: float = _health_state.get_health_regen_rate(entity_id)
		if regen_rate <= 0.0:
			continue
		var current: int = context.state.get_health(entity_id)
		var max_hp: int = _health_state.get_max_health(entity_id)
		if max_hp <= 0:
			continue
		if current >= max_hp:
			continue
		# Acumular regeneración para precisión
		var accumulator: float = _health_state.get_regen_accumulator(entity_id)
		accumulator += regen_rate * delta
		var regen_amount: int = int(accumulator)
		if regen_amount > 0:
			accumulator -= float(regen_amount)
			_health_state.set_regen_accumulator(entity_id, accumulator)
			var old_health: int = current
			_apply_heal(context, entity_id, regen_amount, "regen")
			var new_health: int = context.state.get_health(entity_id)
			if new_health != old_health:
				_emit_health_changed(context, entity_id, old_health, new_health, max_hp, "regen")
				# Emitir evento de curación también
				if new_health > old_health:
					var heal_ev: HealEvent = HealEventScript.new(entity_id, new_health - old_health, "regen", [])
					var result := context.bus.emit(heal_ev)
					if not result.ok:
						context.logger.error("HealthSystem heal event failed: " + str(result.error))

func _check_deaths(context: SimulationContext) -> void:
	var entity_ids: Array = _health_state.get_all_entities_with_health()
	for entity_id in entity_ids:
		var current: int = context.state.get_health(entity_id)
		if current <= 0:
			var last_death_tick: int = _health_state.get_last_death_tick(entity_id)
			if last_death_tick < 0:
				# Marcar como muerto (usar tick del kernel si está disponible)
				_health_state.set_last_death_tick(entity_id, 0)  # TODO: obtener tick real
				_emit_death(context, entity_id, "", "health_zero")

func _listen_to_damage_events(_context: SimulationContext) -> void:
	# Este método se suscribe a eventos de daño para emitir eventos de cambio de vida
	# La suscripción se hace en el kernel, no aquí
	pass

func _apply_heal(context: SimulationContext, entity_id: String, amount: int, _source: String) -> void:
	var current: int = context.state.get_health(entity_id)
	var max_hp: int = _health_state.get_max_health(entity_id)
	if max_hp > 0:
		context.state.set_health(entity_id, min(max_hp, current + amount))
	else:
		context.state.set_health(entity_id, current + amount)

func _emit_health_changed(context: SimulationContext, entity_id: String, old_health: int, new_health: int, max_health: int, source: String) -> void:
	var ev: HealthChangedEvent = HealthChangedEventScript.new(entity_id, old_health, new_health, max_health, source)
	var result := context.bus.emit(ev)
	if not result.ok:
		context.logger.error("HealthSystem health_changed event failed: " + str(result.error))

func _emit_death(context: SimulationContext, entity_id: String, killer_id: String, cause: String) -> void:
	var ev: DeathEvent = DeathEventScript.new(entity_id, killer_id, cause)
	var result := context.bus.emit(ev)
	if not result.ok:
		context.logger.error("HealthSystem death event failed: " + str(result.error))

func get_health_state() -> HealthState:
	return _health_state
