# Game: Pickup event. Allowed deps: core types + game types.
class_name PickupEvent
extends EventBase

const PAYLOAD_KEYS := ["pickup_id", "target_id", "tags"]

func _init(pickup_id: String, target_id: String, tags: Array) -> void:
	super._init(GameConstants.EVENT_PICKUP)
	payload = {
		"pickup_id": pickup_id,
		"target_id": target_id,
		"tags": tags
	}

func validate() -> Result:
	var payload := get_payload()
	for key in PAYLOAD_KEYS:
		if not payload.has(key):
			return Result.err_result("PickupEvent missing payload: " + key)
	if not (payload["pickup_id"] is String):
		return Result.err_result("PickupEvent pickup_id must be string")
	if not (payload["target_id"] is String):
		return Result.err_result("PickupEvent target_id must be string")
	if not (payload["tags"] is Array):
		return Result.err_result("PickupEvent tags must be array")
	return Result.ok_result(true)

func get_pickup_id() -> String:
	return String(get_payload()["pickup_id"])

func get_target_id() -> String:
	return String(get_payload()["target_id"])
