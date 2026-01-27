# Game: Project-specific kernel extension. Allowed deps: Godot + Rage Core + game layer.
extends GameKernel
class_name GameKernelGame

var _run_state: RunState
var _level_selector: LevelSelector
var _level_selection_system: LevelSelectionSystem
var _room_combat_system: RoomCombatSystem
var _room_economy_system: RoomEconomySystem
var _shop_offer_system: ShopOfferSystem
var _shop_resolve_system: ShopResolveSystem
var _ability_award_system: AbilityAwardSystem
var _parkour_gate_system: ParkourGateSystem
var _boss_stage_system: BossStageSystem
var _boss_reward_system: BossRewardSystem
var _run_end_system: RunEndSystem
var _auto_reset: bool = true

func _ready() -> void:
	super._ready()
	# Optional Rage Core setup (uncomment to enable).
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
	# Gameplay systems (combat, pickups, surfaces, ladders).
	_combat_system = CombatSystem.new()
	_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 50, _combat_system)
	_pickup_system = PickupSystem.new()
	_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 40, _pickup_system)
	_surface_system = SurfaceSystem.new()
	_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 30, _surface_system)
	# _ladder_system = LadderSystem.new()
	# _pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 20, _ladder_system)
	# Debug: prints pipeline order on boot (requires boot_log enabled).
	_log_pipeline_registration()
	# Content: packs from res://addons/rage_core/data_packs and res://data_packs.
	_load_content_packs()
	# Mods: load and call on_load() in deterministic order.
	_load_mods()
	_run_state = RunState.new()
	_run_state.reset(_seed64)
	_apply_run_config()
	_boot_info("[RUN] reset seed=" + str(_seed64))
	_boot_info("[RUN] start seed=" + str(_seed64))
	var canonical := _run_state.export_canonical()
	var state_hash := StateHasher.hash_canonical_state(canonical)
	_boot_info("[RUN] canonical=hash:" + state_hash)
	_level_selector = LevelSelector.new()
	_level_selection_system = LevelSelectionSystem.new(_run_state, _level_selector)
	_pipeline.register_step(GameConstants.PHASE_POST, 10, _level_selection_system)
	_room_combat_system = RoomCombatSystem.new(_run_state)
	_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 20, _room_combat_system)
	_room_economy_system = RoomEconomySystem.new(_run_state)
	_pipeline.register_step(GameConstants.PHASE_GAMEPLAY, 10, _room_economy_system)
	_ability_award_system = AbilityAwardSystem.new(_run_state)
	_pipeline.register_step(GameConstants.PHASE_POST, 40, _ability_award_system)
	_parkour_gate_system = ParkourGateSystem.new(_run_state)
	_pipeline.register_step(GameConstants.PHASE_POST, 35, _parkour_gate_system)
	_boss_stage_system = BossStageSystem.new(_run_state)
	_pipeline.register_step(GameConstants.PHASE_POST, 33, _boss_stage_system)
	_shop_offer_system = ShopOfferSystem.new(_run_state)
	_pipeline.register_step(GameConstants.PHASE_POST, 30, _shop_offer_system)
	_shop_resolve_system = ShopResolveSystem.new(_run_state)
	_pipeline.register_step(GameConstants.PHASE_POST, 20, _shop_resolve_system)
	_boss_reward_system = BossRewardSystem.new(_run_state)
	_pipeline.register_step(GameConstants.PHASE_POST, 15, _boss_reward_system)
	_run_end_system = RunEndSystem.new(_run_state, _auto_reset)
	_pipeline.register_step(GameConstants.PHASE_POST, 5, _run_end_system)

func get_run_state() -> RunState:
	return _run_state

func _load_content_packs() -> void:
	super._load_content_packs()
	_load_content_packs_from_dir("user://data_packs")

func _apply_run_config() -> void:
	var config_path := "res://game/config/run_config.json"
	if _file_store.exists("user://game_config.json"):
		config_path = "user://game_config.json"
	var res := RunConfig.load(_file_store, config_path)
	if not res.ok:
		_logger.warn("RunConfig load failed: " + str(res.error))
		return
	var config: Dictionary = res.value
	var limit := RunConfig.get_room_limit(config, _run_state.get_room_limit())
	_run_state.set_room_limit(limit)
	_auto_reset = RunConfig.get_auto_reset(config, _auto_reset)

