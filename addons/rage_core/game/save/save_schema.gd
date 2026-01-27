# Game: Save schema helpers. Allowed deps: core types + game types.
class_name SaveSchema

const VERSION := 1

static func encode(state: GameState) -> Dictionary:
	return {
		"version": VERSION,
		"health": state._health,
		"positions": _encode_positions(state)
	}

static func decode(state: GameState, data: Dictionary) -> Result:
	if not data.has("version") or int(data["version"]) != VERSION:
		return Result.err_result("Save version mismatch")
	if not data.has("health") or not (data["health"] is Dictionary):
		return Result.err_result("Save health missing or invalid")
	if not data.has("positions") or not (data["positions"] is Dictionary):
		return Result.err_result("Save positions missing or invalid")
	state._health = data["health"]
	state._positions = _decode_positions(data["positions"])
	return Result.ok_result(true)

static func _encode_positions(state: GameState) -> Dictionary:
	var out := {}
	for key in state._positions.keys():
		var pos: Vec2 = state._positions[key]
		out[key] = {"x": pos.x, "y": pos.y}
	return out

static func _decode_positions(data: Dictionary) -> Dictionary:
	var out := {}
	for key in data.keys():
		var entry = data[key]
		if entry is Dictionary and entry.has("x") and entry.has("y"):
			out[key] = Vec2.new(float(entry["x"]), float(entry["y"]))
	return out
