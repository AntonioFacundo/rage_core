# Core: Input source interface. Allowed deps: none.
class_name IInputSource

func is_action_pressed(_action_id: String) -> bool:
	assert(false, "IInputSource.is_action_pressed not implemented")
	return false

func is_action_just_pressed(_action_id: String) -> bool:
	assert(false, "IInputSource.is_action_just_pressed not implemented")
	return false

func get_axis(_axis_id: String) -> float:
	assert(false, "IInputSource.get_axis not implemented")
	return 0.0
