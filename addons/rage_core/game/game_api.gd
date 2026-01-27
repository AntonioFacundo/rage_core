# Game: Facade for mods. Allowed deps: core types + game types.
class_name GameAPI

const EVENT_DAMAGE := GameConstants.EVENT_DAMAGE
const EVENT_ROOM := GameConstants.EVENT_ROOM
const EVENT_PICKUP := GameConstants.EVENT_PICKUP

var _bus: EventBus
var _core: GameCore
var _state: GameState
var _state_view: GameState.GameStateView
var _logger: ILogger
var _clock: IClock
var _input_registry: InputRegistry
var _input_map: GameInputMap
var _content_registry: ContentRegistry
var _save_store: ISaveStore
var _save_manager: SaveManager
var _rng: IRng

func _init(
		bus: EventBus,
		core: GameCore,
		state: GameState,
		state_view: GameState.GameStateView,
		logger: ILogger,
		clock: IClock,
		input_registry: InputRegistry,
		input_map: GameInputMap,
		content_registry: ContentRegistry,
		save_store: ISaveStore,
		save_manager: SaveManager
	) -> void:
	_bus = bus
	_core = core
	_state = state
	_state_view = state_view
	_logger = logger
	_clock = clock
	_input_registry = input_registry
	_input_map = input_map
	_content_registry = content_registry
	_save_store = save_store
	_save_manager = save_manager
	_rng = core.get_rng()

func subscribe(event_id: String, handler: Callable, priority: int = 0, intercept: bool = false) -> Result:
	var validation := _validate_event_id(event_id)
	if not validation.ok:
		return validation
	var token := _bus.subscribe(event_id, handler, priority, intercept)
	return Result.ok_result(token)

func unsubscribe(token: int) -> bool:
	return _bus.unsubscribe(token)

func emit(event: EventBase) -> Result:
	return _bus.emit(event)

func apply_damage(attacker_id: String, target_id: String, amount: int, tags: Array) -> Result:
	return _core.apply_damage(attacker_id, target_id, amount, tags)

func apply_command(command: ICommand) -> Result:
	return _core.apply_command(command)

func set_movement_config(entity_id: String, config: Movement2DConfig) -> Result:
	return _core.set_movement_config(entity_id, config)

func set_invuln_duration(entity_id: String, duration: float) -> Result:
	return _core.set_invuln_duration(entity_id, duration)

func set_ai_config(entity_id: String, config: AIConfig) -> Result:
	return _core.set_ai_config(entity_id, config)

func get_state() -> GameState.GameStateView:
	return _state_view

func get_logger() -> ILogger:
	return _logger

func get_clock() -> IClock:
	return _clock

func get_rng() -> IRng:
	return _rng

func register_action(action_id: String) -> Result:
	return _input_registry.register_action(action_id)

func register_axis(axis_id: String) -> Result:
	return _input_registry.register_axis(axis_id)

func bind_action(action_id: String, source_action_id: String) -> Result:
	return _input_map.bind_action(action_id, source_action_id)

func bind_axis(axis_id: String, source_axis_id: String) -> Result:
	return _input_map.bind_axis(axis_id, source_axis_id)

func sample_input(input_source: IInputSource) -> InputSnapshot:
	return _input_map.sample(input_source)

func register_content(definition: ContentDef) -> Result:
	return _content_registry.register(definition)

func register_content_type(type_id: String) -> bool:
	return GameConstants.register_content_type(type_id)

func get_content_by_id(content_id: String) -> ContentDef:
	return _content_registry.get_by_id(content_id)

func list_content_by_type(type_id: String) -> Array:
	return _content_registry.list_by_type(type_id)

func save_data(key: String, data: Dictionary) -> Result:
	return _save_store.save_json(key, data)

func load_data(key: String) -> Result:
	return _save_store.load_json(key)

func save_state(key: String) -> Result:
	return _save_manager.save_state(_state, key)

func load_state(key: String) -> Result:
	return _save_manager.load_state(_state, key)

func _validate_event_id(event_id: String) -> Result:
	# Allow core events and custom events (game.* or mod.*)
	# This enables extensibility without modifying the core
	if GameConstants.EVENT_IDS.has(event_id):
		return Result.ok_result(true)
	if event_id.begins_with("game.") or event_id.begins_with("mod."):
		return Result.ok_result(true)
	return Result.err_result("Unknown event id: " + event_id + " (must be in EVENT_IDS or start with 'game.' or 'mod.')")
