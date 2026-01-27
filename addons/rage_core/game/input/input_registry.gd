# Game: Input id registry. Allowed deps: core types + game types.
class_name InputRegistry

var _action_ids := {}
var _axis_ids := {}

func _init() -> void:
	for action_id in GameConstants.ACTION_IDS:
		_action_ids[action_id] = true
	for axis_id in GameConstants.AXIS_IDS:
		_axis_ids[axis_id] = true

func register_action(action_id: String) -> Result:
	if not Ids.is_valid_id(action_id):
		return Result.err_result("Invalid action id: " + action_id)
	_action_ids[action_id] = true
	return Result.ok_result(true)

func register_axis(axis_id: String) -> Result:
	if not Ids.is_valid_id(axis_id):
		return Result.err_result("Invalid axis id: " + axis_id)
	_axis_ids[axis_id] = true
	return Result.ok_result(true)

func has_action(action_id: String) -> bool:
	return _action_ids.has(action_id)

func has_axis(axis_id: String) -> bool:
	return _axis_ids.has(axis_id)

func list_actions() -> Array:
	var result := _action_ids.keys()
	result.sort()
	return result

func list_axes() -> Array:
	var result := _axis_ids.keys()
	result.sort()
	return result
