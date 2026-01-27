# Game: Immutable input snapshot for simulation. Allowed deps: core types + game types.
class_name InputSnapshot

var _pressed := {}
var _just_pressed := {}
var _axes := {}

func _init(pressed: Dictionary, just_pressed: Dictionary, axes: Dictionary) -> void:
	_pressed = pressed
	_just_pressed = just_pressed
	_axes = axes

func is_pressed(action_id: String) -> bool:
	return bool(_pressed.get(action_id, false))

func is_just_pressed(action_id: String) -> bool:
	return bool(_just_pressed.get(action_id, false))

func get_axis(axis_id: String) -> float:
	return float(_axes.get(axis_id, 0.0))

func get_action_ids() -> Array:
	var ids := _pressed.keys()
	ids.sort()
	return ids

func get_axis_ids() -> Array:
	var ids := _axes.keys()
	ids.sort()
	return ids
