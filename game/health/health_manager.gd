# Game: Health manager facade. Uses GameAPI and HealthSystem.
class_name HealthManager

const HealthChangedEvent = preload("res://game/health/events/health_changed_event.gd")
const DeathEvent = preload("res://game/health/events/death_event.gd")
const HealEvent = preload("res://game/health/events/heal_event.gd")
const DamageEvent = preload("res://addons/rage_core/game/events/damage_event.gd")

var _api: GameAPI
var _health_system: HealthSystem
var _health_state: HealthState

func _init(api: GameAPI, health_system: HealthSystem) -> void:
	_api = api
	_health_system = health_system
	_health_state = health_system.get_health_state()
	_setup_damage_listener()

func _setup_damage_listener() -> void:
	# Suscribirse a eventos de daño para emitir eventos de cambio de vida
	var result := _api.subscribe(GameAPI.EVENT_DAMAGE, _on_damage_received)
	if not result.ok:
		_api.get_logger().error("HealthManager: failed to subscribe to damage events: " + str(result.error))

func _on_damage_received(ev: DamageEvent) -> void:
	if ev.is_cancelled():
		return
	var target_id: String = ev.get_target_id()
	var old_health: int = _api.get_state().get_health(target_id)
	# El daño ya se aplicó en GameCore, solo necesitamos emitir el evento de cambio
	var new_health: int = _api.get_state().get_health(target_id)
	var max_health: int = _health_state.get_max_health(target_id)
	if max_health <= 0:
		max_health = new_health  # Fallback
	if old_health != new_health:
		var health_ev: HealthChangedEvent = HealthChangedEvent.new(target_id, old_health, new_health, max_health, "damage")
		var result := _api.emit(health_ev)
		if not result.ok:
			_api.get_logger().error("HealthManager: failed to emit health_changed event: " + str(result.error))

func set_max_health(entity_id: String, value: int, source: String = "") -> void:
	if value <= 0:
		return
	var old_max: int = _health_state.get_max_health(entity_id)
	_health_state.set_max_health(entity_id, value)
	# Ajustar vida actual si excede el nuevo máximo
	var current: int = _api.get_state().get_health(entity_id)
	if current > value:
		_api.get_state().set_health(entity_id, value)
	# Emitir evento si cambió
	if old_max != value:
		# TODO: crear MaxHealthChangedEvent si se necesita
		pass

func set_health_regen_rate(entity_id: String, rate: float) -> void:
	_health_state.set_health_regen_rate(entity_id, rate)

func apply_heal(entity_id: String, amount: int, source: String = "", tags: Array = []) -> void:
	if amount <= 0:
		return
	var ev: HealEvent = HealEvent.new(entity_id, amount, source, tags)
	var result := _api.emit(ev)
	if not result.ok:
		_api.get_logger().error("HealthManager: failed to emit heal event: " + str(result.error))
		return
	if ev.is_cancelled():
		return
	var old_health: int = _api.get_state().get_health(entity_id)
	var max_hp: int = _health_state.get_max_health(entity_id)
	var new_health: int
	if max_hp > 0:
		new_health = min(max_hp, old_health + ev.get_amount())
	else:
		new_health = old_health + ev.get_amount()
	_api.get_state().set_health(entity_id, new_health)
	if old_health != new_health:
		var health_ev: HealthChangedEvent = HealthChangedEvent.new(entity_id, old_health, new_health, max_hp, source)
		var health_result := _api.emit(health_ev)
		if not health_result.ok:
			_api.get_logger().error("HealthManager: failed to emit health_changed event: " + str(health_result.error))

func get_max_health(entity_id: String) -> int:
	return _health_state.get_max_health(entity_id)

func get_health_regen_rate(entity_id: String) -> float:
	return _health_state.get_health_regen_rate(entity_id)
