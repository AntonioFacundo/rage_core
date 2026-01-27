# Game: Health changed event payload. Uses Rage Core EventBase.
class_name HealthChangedEvent
extends EventBase

const ID := "game.health.changed"

func _init(_entity_id: String, _old_health: int, _new_health: int, _max_health: int, _source: String = "") -> void:
	super._init(ID)
	payload = {
		"entity_id": _entity_id,
		"old_health": _old_health,
		"new_health": _new_health,
		"max_health": _max_health,
		"source": _source
	}

func get_entity_id() -> String:
	return String(payload.get("entity_id", ""))

func get_old_health() -> int:
	return int(payload.get("old_health", 0))

func get_new_health() -> int:
	return int(payload.get("new_health", 0))

func get_max_health() -> int:
	return int(payload.get("max_health", 0))

func get_source() -> String:
	return String(payload.get("source", ""))

func validate() -> Result:
	var entity_id := get_entity_id()
	var old_health := get_old_health()
	var new_health := get_new_health()
	var max_health := get_max_health()
	if not Ids.is_valid_id(entity_id):
		return Result.err_result("Invalid entity_id")
	if old_health < 0:
		return Result.err_result("old_health must be >= 0")
	if new_health < 0:
		return Result.err_result("new_health must be >= 0")
	if max_health <= 0:
		return Result.err_result("max_health must be > 0")
	if new_health > max_health:
		return Result.err_result("new_health cannot exceed max_health")
	return Result.ok_result(true)
