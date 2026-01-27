# Game: Health state extension using GameState. No modifications to core.
class_name HealthState

var _max_health := {}
var _health_regen_rate := {}
var _last_death_tick := {}
var _regen_accumulator := {}

func get_max_health(entity_id: String) -> int:
	return int(_max_health.get(entity_id, 0))

func set_max_health(entity_id: String, value: int) -> void:
	if value <= 0:
		return
	_max_health[entity_id] = value

func get_health_regen_rate(entity_id: String) -> float:
	return float(_health_regen_rate.get(entity_id, 0.0))

func set_health_regen_rate(entity_id: String, rate: float) -> void:
	_health_regen_rate[entity_id] = rate

func get_last_death_tick(entity_id: String) -> int:
	return int(_last_death_tick.get(entity_id, -1))

func set_last_death_tick(entity_id: String, tick: int) -> void:
	_last_death_tick[entity_id] = tick

func get_regen_accumulator(entity_id: String) -> float:
	return float(_regen_accumulator.get(entity_id, 0.0))

func set_regen_accumulator(entity_id: String, value: float) -> void:
	_regen_accumulator[entity_id] = value

func get_all_entities_with_health() -> Array:
	var entities: Array = []
	entities.append_array(_max_health.keys())
	return entities
