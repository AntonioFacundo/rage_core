# Game: Death event payload. Uses Rage Core EventBase.
class_name DeathEvent
extends EventBase

const ID := "game.health.death"

func _init(_entity_id: String, _killer_id: String = "", _cause: String = "") -> void:
	super._init(ID)
	payload = {
		"entity_id": _entity_id,
		"killer_id": _killer_id,
		"cause": _cause
	}

func get_entity_id() -> String:
	return String(payload.get("entity_id", ""))

func get_killer_id() -> String:
	return String(payload.get("killer_id", ""))

func get_cause() -> String:
	return String(payload.get("cause", ""))

func validate() -> Result:
	var entity_id := get_entity_id()
	if not Ids.is_valid_id(entity_id):
		return Result.err_result("Invalid entity_id")
	return Result.ok_result(true)
