# Toolkit: Headless simulator for rapid development and testing. No Godot dependencies.
class_name HeadlessSimulator

var _bus: EventBus
var _state: GameState
var _core: GameCore
var _pipeline: SimulationPipeline
var _logger: ILogger
var _rng: DeterministicRng
var _tick_index: int = 0
var _fixed_dt: float = 1.0 / 60.0

func _init(
	bus: EventBus,
	state: GameState,
	core: GameCore,
	pipeline: SimulationPipeline,
	logger: ILogger,
	rng: DeterministicRng
) -> void:
	_bus = bus
	_state = state
	_core = core
	_pipeline = pipeline
	_logger = logger
	_rng = rng

# Run simulation for specified number of ticks
func simulate_ticks(tick_count: int, input_snapshot: InputSnapshot = null) -> Dictionary:
	var results := {
		"ticks_executed": 0,
		"final_state": {},
		"events_emitted": [],
		"errors": []
	}
	
	if input_snapshot == null:
		input_snapshot = InputSnapshot.new()
	
	# Create mock sensors for headless simulation
	var mock_physics := _MockPhysics2D.new()
	var mock_combat_sensor := _MockCombatSensor2D.new()
	var mock_trigger_sensor := _MockTriggerSensor2D.new()
	var mock_content_registry := ContentRegistry.new()
	
	for i in range(tick_count):
		var context := SimulationContext.new(
			_state,
			input_snapshot,
			mock_physics,
			mock_combat_sensor,
			mock_trigger_sensor,
			_bus,
			mock_content_registry,
			_logger,
			_core
		)
		
		# Capture events emitted during this tick
		var tick_events: Array = []
		var event_capture_token := _bus.subscribe("game.damage", func(ev): tick_events.append(ev.get_id()))
		_bus.subscribe("game.room", func(ev): tick_events.append(ev.get_id()))
		_bus.subscribe("game.pickup", func(ev): tick_events.append(ev.get_id()))
		
		_pipeline.run(context, _fixed_dt)
		
		_bus.unsubscribe(event_capture_token)
		_tick_index += 1
		results["ticks_executed"] += 1
		if tick_events.size() > 0:
			results["events_emitted"].append({
				"tick": _tick_index,
				"events": tick_events
			})
	
	results["final_state"] = _state.export_canonical()
	return results

# Simulate a specific system in isolation
func simulate_system(system: SimulationStep, initial_state: Dictionary = {}, tick_count: int = 1) -> Dictionary:
	# Set initial state
	for key in initial_state.keys():
		if key == "health":
			for pair in initial_state[key]:
				_state.set_health(pair[0], pair[1])
		# Add more state initialization as needed
	
	var results := {
		"system": system.get_script().resource_path if system.get_script() else "unknown",
		"initial_state": initial_state,
		"final_state": {},
		"ticks": tick_count
	}
	
	var mock_context := _create_mock_context()
	
	for i in range(tick_count):
		system.run(mock_context, _fixed_dt)
	
	results["final_state"] = _state.export_canonical()
	return results

# Run simulation until condition is met
func simulate_until(condition: Callable, max_ticks: int = 1000) -> Dictionary:
	var input_snapshot := InputSnapshot.new()
	var mock_physics := _MockPhysics2D.new()
	var mock_combat_sensor := _MockCombatSensor2D.new()
	var mock_trigger_sensor := _MockTriggerSensor2D.new()
	var mock_content_registry := ContentRegistry.new()
	
	for i in range(max_ticks):
		var context := SimulationContext.new(
			_state,
			input_snapshot,
			mock_physics,
			mock_combat_sensor,
			mock_trigger_sensor,
			_bus,
			mock_content_registry,
			_logger,
			_core
		)
		
		_pipeline.run(context, _fixed_dt)
		_tick_index += 1
		
		if condition.call():
			return {
				"stopped_at_tick": _tick_index,
				"condition_met": true,
				"final_state": _state.export_canonical()
			}
	
	return {
		"stopped_at_tick": _tick_index,
		"condition_met": false,
		"max_ticks_reached": true,
		"final_state": _state.export_canonical()
	}

func _create_mock_context() -> SimulationContext:
	var mock_physics := _MockPhysics2D.new()
	var mock_combat_sensor := _MockCombatSensor2D.new()
	var mock_trigger_sensor := _MockTriggerSensor2D.new()
	var mock_content_registry := ContentRegistry.new()
	var input_snapshot := InputSnapshot.new()
	
	return SimulationContext.new(
		_state,
		input_snapshot,
		mock_physics,
		mock_combat_sensor,
		mock_trigger_sensor,
		_bus,
		mock_content_registry,
		_logger,
		_core
	)

func get_tick_index() -> int:
	return _tick_index

func reset() -> void:
	_tick_index = 0

class _MockPhysics2D:
	extends IPhysics2D
	func register_body(_body_id: String, _body) -> Result:
		return Result.ok_result(true)
	func get_position(_body_id: String) -> Vec2:
		return Vec2.new()
	func set_position(_body_id: String, _pos: Vec2) -> void:
		pass
	func move_and_slide(_body_id: String, _velocity: Vec2, _delta: float) -> Vec2:
		return Vec2.new()

class _MockCombatSensor2D:
	extends ICombatSensor2D
	func register_hit(_hit: Hit2D) -> void:
		pass
	func pop_hits() -> Array:
		return []

class _MockTriggerSensor2D:
	extends ITriggerSensor2D
	func register_trigger(_trigger: Trigger2D) -> void:
		pass
	func pop_triggers() -> Array:
		return []
