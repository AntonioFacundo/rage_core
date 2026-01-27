# Game: Simple AI system (idle/patrol/chase). Allowed deps: core types + game types.
class_name AISystem
extends SimulationStep

var _entities: Array = []

func register_entity(entity_id: String) -> Result:
	if not Ids.is_valid_id(entity_id):
		return Result.err_result("Invalid entity id: " + entity_id)
	if _entities.has(entity_id):
		return Result.ok_result(true)
	_entities.append(entity_id)
	return Result.ok_result(true)

func run(context: SimulationContext, _delta: float) -> void:
	for entity_id in _entities:
		var config := context.state.get_ai_config(entity_id)
		if config == null:
			continue
		var input := Movement2DInput.new()
		if config.mode == AIConfig.MODE_PATROL:
			input.move_x = _patrol_move(context.state, entity_id, config)
		elif config.mode == AIConfig.MODE_CHASE:
			input.move_x = _chase_move(context.state, entity_id, config)
		context.state.set_movement_input(entity_id, input)

func _patrol_move(state: GameState, entity_id: String, config: AIConfig) -> float:
	var pos := state.get_position(entity_id)
	if pos.x <= config.patrol_left:
		return 1.0
	if pos.x >= config.patrol_right:
		return -1.0
	return 1.0

func _chase_move(state: GameState, entity_id: String, config: AIConfig) -> float:
	if config.target_id == "":
		return 0.0
	var pos := state.get_position(entity_id)
	var target := state.get_position(config.target_id)
	if abs(target.x - pos.x) < 2.0:
		return 0.0
	return 1.0 if target.x > pos.x else -1.0
