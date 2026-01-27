# Game: Replay player. Allowed deps: core types + game types.
class_name ReplayPlayer

var _stream: ReplayStream
var _prev_pressed := {}

func load_json(data: Dictionary) -> void:
	_stream = ReplayStream.from_dict(data)

func get_frame(tick_index: int) -> ReplayFrame:
	if _stream == null:
		return null
	return _stream.get_frame(tick_index)

func get_metadata() -> Dictionary:
	if _stream == null:
		return {}
	return _stream.metadata

func build_snapshot(frame: ReplayFrame, registry: InputRegistry) -> InputSnapshot:
	var pressed := {}
	var just_pressed := {}
	var axes := {}

	var action_ids := registry.list_actions()
	for action_id in action_ids:
		pressed[action_id] = false
	for entry in frame.actions:
		if entry is Array and entry.size() >= 2:
			var action_id := String(entry[0])
			pressed[action_id] = bool(entry[1])
	for action_id in action_ids:
		var prev := bool(_prev_pressed.get(action_id, false))
		var now := bool(pressed.get(action_id, false))
		just_pressed[action_id] = now and not prev
	_prev_pressed = pressed.duplicate()

	var axis_ids := registry.list_axes()
	for axis_id in axis_ids:
		axes[axis_id] = 0.0
	for entry in frame.axes:
		if entry is Array and entry.size() >= 2:
			var axis_id := String(entry[0])
			axes[axis_id] = float(entry[1])

	return InputSnapshot.new(pressed, just_pressed, axes)
