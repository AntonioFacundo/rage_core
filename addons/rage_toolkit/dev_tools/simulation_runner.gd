# Toolkit: High-level simulation runner for rapid prototyping.
class_name SimulationRunner

var _simulator: HeadlessSimulator
var _api: GameAPI
var _pipeline: SimulationPipeline

func _init(api: GameAPI, pipeline: SimulationPipeline, simulator: HeadlessSimulator) -> void:
	_api = api
	_pipeline = pipeline
	_simulator = simulator

# Quick test: Run a system for N ticks and return results
static func quick_test_system(
	system: SimulationStep,
	initial_state: Dictionary = {},
	tick_count: int = 100
) -> Dictionary:
	var bus := EventBus.new()
	var state := GameState.new()
	var logger := _TestLogger.new()
	var rng := DeterministicRng.new()
	rng.seed(12345)  # Fixed seed for determinism
	var core := GameCore.new(bus, state, logger, rng)
	var pipeline := SimulationPipeline.new()
	var simulator := HeadlessSimulator.new(bus, state, core, pipeline, logger, rng)
	
	# Register the system
	pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 50, system)
	
	return simulator.simulate_system(system, initial_state, tick_count)

# Quick test: Simulate a full game scenario
static func quick_test_scenario(
	systems: Array,
	initial_state: Dictionary = {},
	tick_count: int = 1000
) -> Dictionary:
	var bus := EventBus.new()
	var state := GameState.new()
	var logger := _TestLogger.new()
	var rng := DeterministicRng.new()
	rng.seed(12345)
	var core := GameCore.new(bus, state, logger, rng)
	var pipeline := SimulationPipeline.new()
	var simulator := HeadlessSimulator.new(bus, state, core, pipeline, logger, rng)
	
	# Register all systems
	for i in range(systems.size()):
		var system: SimulationStep = systems[i]
		pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 50 - i, system)
	
	# Set initial state
	for key in initial_state.keys():
		if key == "health":
			for pair in initial_state[key]:
				state.set_health(pair[0], pair[1])
	
	return simulator.simulate_ticks(tick_count)

class _TestLogger:
	extends ILogger
	func info(_message: String) -> void:
		pass
	func warn(_message: String) -> void:
		pass
	func error(_message: String) -> void:
		pass
