# Game: Input mapping and sampling. Allowed deps: core types + game types.
class_name GameInputMap

var _registry: InputRegistry
var _action_bindings := {}
var _axis_bindings := {}

func _init(registry: InputRegistry) -> void:
	_registry = registry

func bind_action(action_id: String, source_action_id: String) -> Result:
	if not _registry.has_action(action_id):
		return Result.err_result("Unknown action id: " + action_id)
	if not Ids.is_valid_id(source_action_id):
		return Result.err_result("Invalid source action id: " + source_action_id)
	_action_bindings[action_id] = source_action_id
	return Result.ok_result(true)

func bind_axis(axis_id: String, source_axis_id: String) -> Result:
	if not _registry.has_axis(axis_id):
		return Result.err_result("Unknown axis id: " + axis_id)
	if not Ids.is_valid_id(source_axis_id):
		return Result.err_result("Invalid source axis id: " + source_axis_id)
	_axis_bindings[axis_id] = source_axis_id
	return Result.ok_result(true)

func sample(input_source: IInputSource) -> InputSnapshot:
	var pressed := {}
	var just_pressed := {}
	var axes := {}

	for action_id in _registry.list_actions():
		var source_id := String(_action_bindings.get(action_id, action_id))
		pressed[action_id] = input_source.is_action_pressed(source_id)
		just_pressed[action_id] = input_source.is_action_just_pressed(source_id)

	for axis_id in _registry.list_axes():
		var source_id := String(_axis_bindings.get(axis_id, axis_id))
		axes[axis_id] = input_source.get_axis(source_id)

	return InputSnapshot.new(pressed, just_pressed, axes)
