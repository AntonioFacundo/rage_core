# Game: Platformer game kernel. Allowed deps: Godot + Rage Core + game layer.
extends GameKernel
class_name GameKernelGame

var _health_system: HealthSystem
var _health_manager: HealthManager

func _ready() -> void:
	super._ready()
	# Inputs: binds default action ids to Godot input names.
	_bind_default_inputs()
	# Input sampling + AI + trigger buffering.
	_player_input_system = PlayerInputSystem.new()
	_pipeline.register_step(GameConstants.PHASE_INPUT, 100, _player_input_system)
	_ai_system = AISystem.new()
	_pipeline.register_step(GameConstants.PHASE_INPUT, 90, _ai_system)
	_trigger_buffer_system = TriggerBufferSystem.new()
	_pipeline.register_step(GameConstants.PHASE_INPUT, 10, _trigger_buffer_system)
	# Core movement loop + default player entity.
	_movement_system = Movement2DSystem.new()
	_movement_system.register_entity("player")
	_pipeline.register_step(GameConstants.PHASE_MOVEMENT, 100, _movement_system)
	# Gameplay systems (combat, health, pickups, surfaces, ladders).
	_combat_system = CombatSystem.new()
	_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 50, _combat_system)
	_health_system = HealthSystem.new()
	_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 15, _health_system)
	_health_manager = HealthManager.new(_api, _health_system)
	_pickup_system = PickupSystem.new()
	_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 40, _pickup_system)
	_surface_system = SurfaceSystem.new()
	_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 30, _surface_system)
	_ladder_system = LadderSystem.new()
	_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 20, _ladder_system)
	# Debug: prints pipeline order on boot (requires boot_log enabled).
	_log_pipeline_registration()
	# Content: packs from res://addons/rage_core/data_packs and res://data_packs.
	_load_content_packs()
	# Mods: load and call on_load() in deterministic order.
	_load_mods()

func get_health_manager() -> HealthManager:
	return _health_manager

func _load_content_packs() -> void:
	super._load_content_packs()
	_load_content_packs_from_dir("user://data_packs")
