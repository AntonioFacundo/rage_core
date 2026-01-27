# Game: Heal event payload. Uses Rage Core EventBase.
class_name HealEvent
extends EventBase

const ID := "game.health.heal"

func _init(_entity_id: String, _amount: int, _source: String = "", _tags: Array = []) -> void:
	super._init(ID)
	payload = {
		"entity_id": _entity_id,
		"amount": _amount,
		"source": _source,
		"tags": _tags
	}

func get_entity_id() -> String:
	return String(payload.get("entity_id", ""))

func get_amount() -> int:
	return int(payload.get("amount", 0))

func set_amount(value: int) -> void:
	payload["amount"] = value

func get_source() -> String:
	return String(payload.get("source", ""))

func get_tags() -> Array:
	return payload.get("tags", [])

func validate() -> Result:
	var entity_id := get_entity_id()
	var amount := get_amount()
	var tags := get_tags()
	if not Ids.is_valid_id(entity_id):
		return Result.err_result("Invalid entity_id")
	if amount <= 0:
		return Result.err_result("amount must be > 0")
	if typeof(tags) != TYPE_ARRAY:
		return Result.err_result("tags must be an Array")
	for t in tags:
		if typeof(t) != TYPE_STRING:
			return Result.err_result("tags must contain strings only")
	return Result.ok_result(true)
