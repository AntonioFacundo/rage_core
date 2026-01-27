# Game: 2D movement system. Allowed deps: core types + game types.
class_name Movement2DSystem
extends SimulationStep

var _entities: Array = []
var _default_config := Movement2DConfig.new()

func register_entity(entity_id: String) -> Result:
	if not Ids.is_valid_id(entity_id):
		return Result.err_result("Invalid entity id: " + entity_id)
	if _entities.has(entity_id):
		return Result.ok_result(true)
	_entities.append(entity_id)
	return Result.ok_result(true)

func run(context: SimulationContext, delta: float) -> void:
	for entity_id in _entities:
		_run_entity(context, delta, entity_id)

func _run_entity(context: SimulationContext, delta: float, entity_id: String) -> void:
	var state := context.state.get_movement_state(entity_id)
	var config := context.state.get_movement_config(entity_id, _default_config)
	var input := context.state.get_movement_input(entity_id)
	if input == null:
		input = Movement2DInput.new()

	if state.on_ladder and input.jump_pressed:
		state.on_ladder = false
		state.velocity.y = -config.jump_speed

	if input.jump_pressed:
		state.jump_buffer_timer = config.jump_buffer
	state.jump_buffer_timer = max(0.0, state.jump_buffer_timer - delta)

	if state.is_grounded:
		state.coyote_timer = config.coyote_time
	else:
		state.coyote_timer = max(0.0, state.coyote_timer - delta)

	var start_dash := input.dash_pressed and not state.on_ladder and state.dash_timer <= 0.0 and state.dash_cooldown <= 0.0
	if start_dash:
		state.dash_timer = config.dash_time
		state.dash_cooldown = config.dash_cooldown
		state.velocity.y = 0.0
		state.velocity.x = float(state.facing) * config.dash_speed

	if state.dash_timer > 0.0:
		state.dash_timer = max(0.0, state.dash_timer - delta)
		state.velocity.y = 0.0
	else:
		state.dash_cooldown = max(0.0, state.dash_cooldown - delta)

	if state.jump_buffer_timer > 0.0 and (state.is_grounded or state.coyote_timer > 0.0):
		state.velocity.y = -config.jump_speed
		state.jump_buffer_timer = 0.0
		state.coyote_timer = 0.0
		state.is_grounded = false

	if input.jump_released and state.velocity.y < 0.0:
		state.velocity.y *= config.jump_cut_multiplier

	if state.dash_timer <= 0.0 and not state.on_ladder:
		var factors := context.state.get_surface_factors(entity_id)
		var speed_mult := float(factors.get("max_speed_mult", 1.0))
		var accel_mult := float(factors.get("accel_mult", 1.0))
		var decel_mult := float(factors.get("decel_mult", 1.0))
		var slope_mult := _slope_multiplier(state, config, input.move_x)
		state.velocity.x = _apply_horizontal(
			state.velocity.x,
			input.move_x,
			config.max_speed * speed_mult * slope_mult,
			config.acceleration * accel_mult,
			config.deceleration * decel_mult,
			delta
		)
		state.velocity.y = _apply_gravity(state.velocity.y, config, delta, state.is_grounded)
	elif state.on_ladder:
		state.velocity.x = _apply_horizontal(
			state.velocity.x,
			input.move_x,
			config.max_speed,
			config.acceleration,
			config.deceleration,
			delta
		)
		state.velocity.y = input.move_y * config.ladder_speed

	var result := context.physics.move_body(entity_id, state.velocity, delta)
	state.velocity = result.velocity
	state.is_grounded = result.contacts.on_floor
	state.last_floor_angle = result.contacts.floor_angle
	state.last_floor_normal = result.contacts.floor_normal
	context.state.set_position(entity_id, result.position)

func _apply_horizontal(current: float, move_x: float, max_speed: float, accel: float, decel: float, delta: float) -> float:
	if abs(move_x) > 0.01:
		var target := move_x * max_speed
		return _move_toward(current, target, accel * delta)
	return _move_toward(current, 0.0, decel * delta)

func _apply_gravity(current: float, config: Movement2DConfig, delta: float, grounded: bool) -> float:
	if grounded:
		if current > 0.0:
			return 0.0
		return current
	var multiplier := config.fall_gravity_multiplier if current > 0.0 else config.apex_gravity_multiplier
	var next_value := current + (config.gravity * multiplier * delta)
	if next_value > config.max_fall_speed:
		return config.max_fall_speed
	return next_value

func _move_toward(value: float, target: float, delta: float) -> float:
	if value == target:
		return value
	if value < target:
		return min(value + delta, target)
	return max(value - delta, target)

func _slope_multiplier(state: Movement2DState, config: Movement2DConfig, move_x: float) -> float:
	if not state.is_grounded:
		return 1.0
	if state.last_floor_angle <= 0.1:
		return 1.0
	if state.last_floor_angle > config.max_slope_angle:
		return 1.0
	var slope_dir := -1 if state.last_floor_normal.x > 0.0 else 1
	if move_x * slope_dir > 0.0:
		return config.slope_up_multiplier
	if move_x * slope_dir < 0.0:
		return config.slope_down_multiplier
	return 1.0
