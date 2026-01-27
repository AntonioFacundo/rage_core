# Platform/Godot: IInputSource implementation using Input. Allowed deps: Godot APIs only.
class_name GodotInputSource
extends IInputSource

func is_action_pressed(action_id: String) -> bool:
	if not InputMap.has_action(action_id):
		return false
	return Input.is_action_pressed(action_id)

func is_action_just_pressed(action_id: String) -> bool:
	if not InputMap.has_action(action_id):
		return false
	return Input.is_action_just_pressed(action_id)

func get_axis(axis_id: String) -> float:
	# Axis mapping is platform-specific; kernel should map ids to device/axis.
	return 0.0
