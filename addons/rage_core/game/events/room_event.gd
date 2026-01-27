# Game: Room event payload. Allowed deps: core types + game constants.
class_name RoomEvent
extends EventBase

const ID := GameConstants.EVENT_ROOM

func _init(_room_id: String, _action: String) -> void:
	super._init(ID)
	payload = {
		"room_id": _room_id,
		"action": _action
	}

func validate() -> Result:
	var room_id := String(payload.get("room_id", ""))
	var action := String(payload.get("action", ""))
	if not Ids.is_valid_id(room_id):
		return Result.err_result("Invalid room_id")
	if action == "":
		return Result.err_result("action is required")
	return Result.ok_result(true)
