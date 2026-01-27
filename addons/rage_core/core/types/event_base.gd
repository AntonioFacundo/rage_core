# Core: Base event class with cancellation and validation. Allowed deps: core types only.
class_name EventBase

var id: String
var payload: Dictionary = {}
var cancelled: bool = false

func _init(_id: String) -> void:
	id = _id

func get_id() -> String:
	return id

func cancel() -> void:
	cancelled = true

func is_cancelled() -> bool:
	return cancelled

func get_payload() -> Dictionary:
	return payload

func set_payload(data: Dictionary) -> void:
	payload = data

# Override in concrete events to validate payload.
func validate() -> Result:
	return Result.ok_result(true)
