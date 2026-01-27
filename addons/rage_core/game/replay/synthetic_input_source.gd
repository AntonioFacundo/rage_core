# Game: Synthetic deterministic input source for tests. Allowed deps: core types only.
class_name SyntheticInputSource
extends IInputSource

var _tick: int = 0

func set_tick(tick_index: int) -> void:
	_tick = tick_index

func is_action_pressed(action_id: String) -> bool:
	if action_id == GameConstants.ACTION_MOVE_LEFT:
		return (_tick / 30) % 2 == 0
	if action_id == GameConstants.ACTION_MOVE_RIGHT:
		return (_tick / 30) % 2 == 1
	if action_id == GameConstants.ACTION_JUMP:
		return _tick % 30 == 0
	if action_id == GameConstants.ACTION_ATTACK:
		return _tick % 45 == 0
	return false

func is_action_just_pressed(action_id: String) -> bool:
	return is_action_pressed(action_id)

func get_axis(axis_id: String) -> float:
	if axis_id == GameConstants.AXIS_MOVE_X:
		return 1.0 if is_action_pressed(GameConstants.ACTION_MOVE_RIGHT) else -1.0 if is_action_pressed(GameConstants.ACTION_MOVE_LEFT) else 0.0
	if axis_id == GameConstants.AXIS_MOVE_Y:
		return 0.0
	return 0.0
