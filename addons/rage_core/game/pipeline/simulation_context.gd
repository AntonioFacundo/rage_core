# Game: Simulation context bundle. Allowed deps: core types + game types.
class_name SimulationContext

var state: GameState
var input_snapshot: InputSnapshot
var physics: IPhysics2D
var combat_sensor: ICombatSensor2D
var trigger_sensor: ITriggerSensor2D
var bus: EventBus
var content_registry: ContentRegistry
var logger: ILogger
var core: GameCore

func _init(
		state_ref: GameState,
		input_ref: InputSnapshot,
		physics_ref: IPhysics2D,
		combat_ref: ICombatSensor2D,
		trigger_ref: ITriggerSensor2D,
		bus_ref: EventBus,
		content_ref: ContentRegistry,
		logger_ref: ILogger,
		core_ref: GameCore
	) -> void:
	state = state_ref
	input_snapshot = input_ref
	physics = physics_ref
	combat_sensor = combat_ref
	trigger_sensor = trigger_ref
	bus = bus_ref
	content_registry = content_ref
	logger = logger_ref
	core = core_ref
