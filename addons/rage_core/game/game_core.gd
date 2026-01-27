# Game: Deterministic command/event core. Allowed deps: core types + game types.
class_name GameCore

var _bus: EventBus
var _state: GameState
var _logger: ILogger
var _rng: IRng

func _init(bus: EventBus, state: GameState, logger: ILogger, rng: IRng) -> void:
	_bus = bus
	_state = state
	_logger = logger
	_rng = rng

func apply_command(command: ICommand) -> Result:
	# Add new command types and core game rules here.
	if command == null:
		return Result.err_result("Command is null")
	if command is AttackCommand:
		var validation = command.validate()
		if not validation.ok:
			return validation
		var ev := DamageEvent.new(command.attacker_id, command.target_id, command.base_damage, [GameConstants.TAG_PHYSICAL])
		var result := _bus.emit(ev)
		if not result.ok:
			return result
		if not ev.is_cancelled():
			_state.apply_damage(ev.get_target_id(), ev.get_amount())
		return Result.ok_result(true)

	var command_id := command.get_id()
	if command_id == "":
		command_id = "unknown"
	return Result.err_result("Unknown command type: " + command_id)

func apply_damage(attacker_id: String, target_id: String, amount: int, tags: Array) -> Result:
	var ev := DamageEvent.new(attacker_id, target_id, amount, tags)
	var result := _bus.emit(ev)
	if not result.ok:
		return result
	if not ev.is_cancelled():
		_state.apply_damage(ev.get_target_id(), ev.get_amount())
	return Result.ok_result(true)

func set_movement_config(entity_id: String, config: Movement2DConfig) -> Result:
	if not Ids.is_valid_id(entity_id):
		return Result.err_result("Invalid entity id: " + entity_id)
	if config == null:
		return Result.err_result("Movement config is null")
	_state.set_movement_config(entity_id, config)
	return Result.ok_result(true)

func set_invuln_duration(entity_id: String, duration: float) -> Result:
	if not Ids.is_valid_id(entity_id):
		return Result.err_result("Invalid entity id: " + entity_id)
	if duration < 0.0:
		return Result.err_result("Invuln duration must be >= 0")
	_state.set_invuln_duration(entity_id, duration)
	return Result.ok_result(true)

func set_ai_config(entity_id: String, config: AIConfig) -> Result:
	if not Ids.is_valid_id(entity_id):
		return Result.err_result("Invalid entity id: " + entity_id)
	if config == null:
		return Result.err_result("AI config is null")
	_state.set_ai_config(entity_id, config)
	return Result.ok_result(true)

func get_rng() -> IRng:
	return _rng
