# Game: Damage event payload. Allowed deps: core types + game constants.
class_name DamageEvent
extends EventBase

const ID := GameConstants.EVENT_DAMAGE

func _init(_attacker_id: String, _target_id: String, _amount: int, _tags: Array = []) -> void:
	super._init(ID)
	payload = {
		"attacker_id": _attacker_id,
		"target_id": _target_id,
		"amount": _amount,
		"tags": _tags
	}

func get_attacker_id() -> String:
	return String(payload.get("attacker_id", ""))

func get_target_id() -> String:
	return String(payload.get("target_id", ""))

func get_amount() -> int:
	return int(payload.get("amount", 0))

func set_amount(value: int) -> void:
	payload["amount"] = value

func get_tags() -> Array:
	return payload.get("tags", [])

func validate() -> Result:
	var attacker_id := get_attacker_id()
	var target_id := get_target_id()
	var amount := get_amount()
	var tags := get_tags()
	if not Ids.is_valid_id(attacker_id):
		return Result.err_result("Invalid attacker_id")
	if not Ids.is_valid_id(target_id):
		return Result.err_result("Invalid target_id")
	if amount <= 0:
		return Result.err_result("amount must be > 0")
	if typeof(tags) != TYPE_ARRAY:
		return Result.err_result("tags must be an Array")
	for t in tags:
		if typeof(t) != TYPE_STRING:
			return Result.err_result("tags must contain strings only")
	return Result.ok_result(true)
