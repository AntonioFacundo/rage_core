# Game: Replay frame data. Allowed deps: core types + game types.
class_name ReplayFrame

var tick_index: int = 0
var actions: Array = [] # Array of [action_id: String, pressed: bool]
var axes: Array = []    # Array of [axis_id: String, value: float]

func _init(tick: int, actions_data: Array, axes_data: Array) -> void:
	tick_index = tick
	actions = actions_data
	axes = axes_data

func to_dict() -> Dictionary:
	return {
		"tick": tick_index,
		"actions": actions,
		"axes": axes
	}

static func from_dict(data: Dictionary) -> ReplayFrame:
	var tick := int(data.get("tick", 0))
	var actions_data := data.get("actions", [])
	var axes_data := data.get("axes", [])
	if not (actions_data is Array):
		actions_data = []
	if not (axes_data is Array):
		axes_data = []
	return ReplayFrame.new(tick, actions_data, axes_data)
