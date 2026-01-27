# Game: Deterministic state container. Allowed deps: core types only.
class_name GameState

var _health := {}
var _positions := {}
var _movement_states := {}
var _movement_configs := {}
var _movement_inputs := {}
var _ai_configs := {}
var _surface_factors := {}
var _trigger_buffer: Array = []
var _invuln_timers := {}
var _invuln_durations := {}

func get_health(entity_id: String) -> int:
	return int(_health.get(entity_id, 0))

func set_health(entity_id: String, value: int) -> void:
	_health[entity_id] = value

func apply_damage(target_id: String, amount: int) -> void:
	var current := get_health(target_id)
	_health[target_id] = max(0, current - amount)

func set_invuln_duration(entity_id: String, duration: float) -> void:
	_invuln_durations[entity_id] = duration

func get_invuln_duration(entity_id: String, default_value: float) -> float:
	return float(_invuln_durations.get(entity_id, default_value))

func set_invuln_timer(entity_id: String, value: float) -> void:
	_invuln_timers[entity_id] = value

func get_invuln_timer(entity_id: String) -> float:
	return float(_invuln_timers.get(entity_id, 0.0))

func tick_invuln(delta: float) -> void:
	for key in _invuln_timers.keys():
		var current := float(_invuln_timers[key])
		_invuln_timers[key] = max(0.0, current - delta)

func set_position(entity_id: String, position: Vec2) -> void:
	_positions[entity_id] = position.copy()

func get_position(entity_id: String) -> Vec2:
	if _positions.has(entity_id):
		var pos: Vec2 = _positions[entity_id]
		return pos.copy()
	return Vec2.new()

func get_movement_state(entity_id: String) -> Movement2DState:
	if not _movement_states.has(entity_id):
		_movement_states[entity_id] = Movement2DState.new()
	return _movement_states[entity_id]

func set_movement_config(entity_id: String, config: Movement2DConfig) -> void:
	_movement_configs[entity_id] = config

func get_movement_config(entity_id: String, default_config: Movement2DConfig) -> Movement2DConfig:
	if _movement_configs.has(entity_id):
		return _movement_configs[entity_id]
	return default_config

func set_movement_input(entity_id: String, input: Movement2DInput) -> void:
	_movement_inputs[entity_id] = input

func get_movement_input(entity_id: String) -> Movement2DInput:
	return _movement_inputs.get(entity_id, null)

func clear_movement_inputs() -> void:
	_movement_inputs.clear()

func set_ai_config(entity_id: String, config: AIConfig) -> void:
	_ai_configs[entity_id] = config

func get_ai_config(entity_id: String) -> AIConfig:
	return _ai_configs.get(entity_id, null)

func set_surface_factors(entity_id: String, factors: Dictionary) -> void:
	_surface_factors[entity_id] = factors

func get_surface_factors(entity_id: String) -> Dictionary:
	return _surface_factors.get(entity_id, {})

func set_trigger_buffer(triggers: Array) -> void:
	_trigger_buffer = triggers

func get_trigger_buffer() -> Array:
	return _trigger_buffer

func export_canonical() -> Dictionary:
	return {
		"health": _sorted_int_map(_health),
		"positions": _sorted_vec2_map(_positions),
		"invuln_timers": _sorted_float_map(_invuln_timers),
		"invuln_durations": _sorted_float_map(_invuln_durations),
		"movement": _sorted_movement_state_map(_movement_states),
		"movement_config": _sorted_movement_config_map(_movement_configs),
		"movement_input": _sorted_movement_input_map(_movement_inputs),
		"ai_config": _sorted_ai_config_map(_ai_configs),
		"surface_factors": _sorted_surface_factors_map(_surface_factors),
		"trigger_buffer": _sorted_trigger_buffer(_trigger_buffer)
	}

func _sorted_keys(map: Dictionary) -> Array:
	var keys := map.keys()
	keys.sort()
	return keys

func _sorted_int_map(map: Dictionary) -> Array:
	var out: Array = []
	var keys := _sorted_keys(map)
	for key in keys:
		out.append([key, int(map[key])])
	return out

func _sorted_float_map(map: Dictionary) -> Array:
	var out: Array = []
	var keys := _sorted_keys(map)
	for key in keys:
		out.append([key, float(map[key])])
	return out

func _sorted_vec2_map(map: Dictionary) -> Array:
	var out: Array = []
	var keys := _sorted_keys(map)
	for key in keys:
		var pos: Vec2 = map[key]
		out.append([key, pos.x, pos.y])
	return out

func _sorted_movement_state_map(map: Dictionary) -> Array:
	var out: Array = []
	var keys := _sorted_keys(map)
	for key in keys:
		var s: Movement2DState = map[key]
		out.append([
			key,
			s.velocity.x, s.velocity.y,
			s.facing,
			s.is_grounded,
			s.jump_buffer_timer,
			s.coyote_timer,
			s.dash_timer,
			s.dash_cooldown,
			s.last_floor_angle,
			s.last_floor_normal.x,
			s.last_floor_normal.y,
			s.on_ladder
		])
	return out

func _sorted_movement_config_map(map: Dictionary) -> Array:
	var out: Array = []
	var keys := _sorted_keys(map)
	for key in keys:
		var c: Movement2DConfig = map[key]
		out.append([
			key,
			c.max_speed,
			c.acceleration,
			c.deceleration,
			c.gravity,
			c.max_fall_speed,
			c.jump_speed,
			c.coyote_time,
			c.jump_buffer,
			c.jump_cut_multiplier,
			c.apex_gravity_multiplier,
			c.fall_gravity_multiplier,
			c.dash_speed,
			c.dash_time,
			c.dash_cooldown,
			c.max_slope_angle,
			c.slope_up_multiplier,
			c.slope_down_multiplier,
			c.ladder_speed
		])
	return out

func _sorted_movement_input_map(map: Dictionary) -> Array:
	var out: Array = []
	var keys := _sorted_keys(map)
	for key in keys:
		var input: Movement2DInput = map[key]
		out.append([
			key,
			input.move_x,
			input.move_y,
			input.jump_pressed,
			input.jump_released,
			input.dash_pressed
		])
	return out

func _sorted_ai_config_map(map: Dictionary) -> Array:
	var out: Array = []
	var keys := _sorted_keys(map)
	for key in keys:
		var config: AIConfig = map[key]
		out.append([
			key,
			config.mode,
			config.patrol_left,
			config.patrol_right,
			config.target_id
		])
	return out

func _sorted_surface_factors_map(map: Dictionary) -> Array:
	var out: Array = []
	var keys := _sorted_keys(map)
	for key in keys:
		var factors = map[key]
		if factors is Dictionary:
			var factor_keys = factors.keys()
			factor_keys.sort()
			var pairs: Array = []
			for fkey in factor_keys:
				pairs.append([fkey, factors[fkey]])
			out.append([key, pairs])
		else:
			out.append([key, []])
	return out

func _sorted_trigger_buffer(triggers: Array) -> Array:
	var list: Array = []
	for entry in triggers:
		if entry is Trigger2D:
			var tags = entry.tags
			if tags is Array:
				tags = tags.duplicate()
				tags.sort()
			list.append([
				entry.trigger_id,
				entry.target_id,
				entry.action,
				entry.point.x,
				entry.point.y,
				tags
			])
	list.sort_custom(func(a, b):
		if a[0] == b[0]:
			if a[1] == b[1]:
				return String(a[2]) < String(b[2])
			return String(a[1]) < String(b[1])
		return String(a[0]) < String(b[0])
	)
	return list


func view() -> GameStateView:
	return GameStateView.new(self)

class GameStateView:
	var _state: GameState

	func _init(state: GameState) -> void:
		_state = state

	func get_health(entity_id: String) -> int:
		return _state.get_health(entity_id)

	func get_position(entity_id: String) -> Vec2:
		return _state.get_position(entity_id)
