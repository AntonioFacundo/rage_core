# Kernel: Assembles modules and runs the loop. Allowed deps: Godot + all layers.
extends Node
class_name GameKernel

const CORE_VERSION := preload("res://addons/rage_core/core/version.gd").CORE_VERSION
const GAME_VERSION := preload("res://addons/rage_core/game/version.gd").GAME_VERSION

var _logger: GodotLogger
var _file_store: GodotFileStore
var _input: GodotInputSource
var _clock: GodotClock
var _save_store: GodotSaveStore
var _save_manager: SaveManager
var _bus: EventBus
var _state: GameState
var _core: GameCore
var _api: GameAPI
var _input_override: IInputSource
var _input_registry: InputRegistry
var _input_map: GameInputMap
var _content_registry: ContentRegistry
var _content_pack_loader: ContentPackLoader
var _physics_2d: GodotPhysics2D
var _pipeline: SimulationPipeline
var _movement_system: Movement2DSystem
var _combat_sensor: GodotCombatSensor2D
var _combat_system: CombatSystem
var _trigger_sensor: GodotTriggerSensor2D
var _pickup_system: PickupSystem
var _player_input_system: PlayerInputSystem
var _ai_system: AISystem
var _surface_system: SurfaceSystem
var _trigger_buffer_system: TriggerBufferSystem
var _ladder_system: LadderSystem
var _mods: Array = []
var _mod_loader: ModLoader
var _rng: DeterministicRng
var _seed8: String = ""
var _seed64: int = 0
var _tick_rate: int = 60
var _fixed_dt: float = 1.0 / 60.0
var _accumulator: float = 0.0
var _max_ticks_per_frame: int = 5
var _replay_mode: String = "live"
var _replay_path: String = "user://rage_replay.rage_replay.json"
var _replay_recorder: ReplayRecorder
var _replay_player: ReplayPlayer
var _tick_index: int = 0
var _hash_log: Array = []
var _expected_hashes := {}
var _replay_metadata: Dictionary = {}
var _loaded_mods_meta: Array = []
var _boot_log_enabled: bool = false
var _boot_warn_count: int = 0
var _boot_pack_count: int = 0
var _boot_mod_count: int = 0
var _boot_system_count: int = 0

func _ready() -> void:
	_logger = GodotLogger.new()
	_boot_log_enabled = _resolve_boot_log_enabled()
	_boot_info("[BOOT] stage=init")
	_file_store = GodotFileStore.new()
	_input = GodotInputSource.new()
	_clock = GodotClock.new()
	_rng = DeterministicRng.new()
	_replay_mode = _resolve_replay_mode()
	_replay_path = _resolve_replay_path()
	_load_replay_player()
	_fixed_dt = _resolve_fixed_dt()
	_max_ticks_per_frame = _resolve_max_ticks_per_frame()
	_seed8 = _resolve_seed8()
	_seed64 = _resolve_seed64(_seed8)
	_rng.seed(_seed64)
	_save_store = GodotSaveStore.new()
	_save_manager = SaveManager.new(_save_store, _logger)
	_bus = EventBus.new()
	_state = GameState.new()
	_core = GameCore.new(_bus, _state, _logger, _rng)
	_input_registry = InputRegistry.new()
	_input_map = GameInputMap.new(_input_registry)
	_content_registry = ContentRegistry.new()
	_content_pack_loader = ContentPackLoader.new(_content_registry)
	_physics_2d = GodotPhysics2D.new()
	_combat_sensor = GodotCombatSensor2D.new()
	_trigger_sensor = GodotTriggerSensor2D.new()
	_api = GameAPI.new(
		_bus,
		_core,
		_state,
		_state.view(),
		_logger,
		_clock,
		_input_registry,
		_input_map,
		_content_registry,
		_save_store,
		_save_manager
	)
	_mod_loader = ModLoader.new()
	_pipeline = SimulationPipeline.new()

	_validate_no_godot_usage()
	_log_coupling_warnings()
	_start_recording_if_needed()
	_boot_info(_build_boot_summary())
	# No built-in example commands in production.

func _process(_delta: float) -> void:
	_accumulator += _delta
	var ticks := 0
	while _accumulator >= _fixed_dt and ticks < _max_ticks_per_frame:
		var snapshot := _get_snapshot_for_tick()
		if snapshot == null:
			break
		_state.clear_movement_inputs()
		var context := SimulationContext.new(
			_state,
			snapshot,
			_physics_2d,
			_combat_sensor,
			_trigger_sensor,
			_bus,
			_content_registry,
			_logger,
			_core
		)
		_pipeline.run(context, _fixed_dt)
		_handle_post_tick(snapshot)
		_accumulator -= _fixed_dt
		_tick_index += 1
		ticks += 1

func get_api() -> GameAPI:
	return _api

func get_tick_index() -> int:
	return _tick_index

func set_input_source(source: IInputSource) -> void:
	_input_override = source

func register_body(body_id: String, body: CharacterBody2D) -> Result:
	var res := _physics_2d.register_body(body_id, body)
	if res.ok:
		_state.set_position(body_id, Vec2.new(body.global_position.x, body.global_position.y))
	return res

func register_movement_entity(entity_id: String) -> Result:
	return _movement_system.register_entity(entity_id)

func register_hit(hit: Hit2D) -> void:
	_combat_sensor.register_hit(hit)

func register_trigger(trigger: Trigger2D) -> void:
	_trigger_sensor.register_trigger(trigger)

func register_ai_entity(entity_id: String, config: AIConfig) -> Result:
	_state.set_ai_config(entity_id, config)
	return _ai_system.register_entity(entity_id)

func _load_mods() -> void:
	_mods = _discover_mods_in_dir("res://mods")
	var manifests: Array = []
	for mod in _mods:
		manifests.append(mod.get_manifest())

	var mod_by_id := {}
	for mod in _mods:
		if not (mod is ModBase):
			continue
		var manifest = mod.get_manifest()
		if manifest != null:
			mod_by_id[manifest.id] = mod

	var order := _mod_loader.resolve_order(manifests)
	if order.ok:
		_boot_mod_count = order.value.size()
		var idx := 0
		for manifest in order.value:
			idx += 1
			var mod_path := ""
			var mod_inst: ModBase = mod_by_id.get(manifest.id, null)
			if mod_inst != null:
				var script := mod_inst.get_script()
				if script != null:
					mod_path = String(script.resource_path)
			var line := "[MOD] idx=" + str(idx)
			line += " id=" + str(manifest.id)
			line += " version=" + str(manifest.version)
			line += " order_hint=" + str(manifest.load_order_hint)
			line += " requires_core=" + str(manifest.requires_core)
			line += " requires_game=" + str(manifest.requires_game)
			if mod_path != "":
				line += " path=" + mod_path
			_boot_info(line)
	else:
		_boot_warn("[WARN][COUPLING] rule=mod_order_resolution error=" + str(order.error))

	var result := _mod_loader.load(_mods, manifests, _api, CORE_VERSION, GAME_VERSION)
	if not result.ok:
		_logger.error("Mod load failed: " + str(result.error))
	_loaded_mods_meta = _build_mods_meta(manifests)

func _discover_mods_in_dir(path: String) -> Array:
	var results: Array = []
	var dir := DirAccess.open(path)
	if dir == null:
		return results
	var entries := _list_dir_entries_sorted(dir)
	for entry in entries:
		var full = path + "/" + entry
		if DirAccess.dir_exists_absolute(full):
			results.append_array(_discover_mods_in_dir(full))
		elif entry.ends_with(".gd"):
			var script = load(full)
			if script == null:
				_logger.error("Failed to load mod script: " + full)
			else:
				var instance = script.new()
				if instance is ModBase:
					results.append(instance)
	return results

func _load_content_packs() -> void:
	_load_content_packs_from_dir("res://addons/rage_core/data_packs")
	_load_content_packs_from_dir("res://data_packs")

func _load_content_packs_from_dir(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	var entries := _list_dir_entries_sorted(dir)
	var pack_files: Array = []
	for name in entries:
		if name.ends_with(".json"):
			pack_files.append(name)
	_boot_info("[BOOT] stage=pack_discovery path=" + path + " count=" + str(pack_files.size()))
	var idx := 0
	for name in pack_files:
		idx += 1
		if not name.ends_with(".json"):
			continue
		var file_path = path + "/" + name
		var res := _file_store.read_text(file_path)
		if res.ok:
			var parsed = JSON.parse_string(res.value)
			if parsed is Dictionary:
				var pack_id := String(parsed.get("pack_id", ""))
				_boot_pack_count += 1
				_boot_info("[PACK] idx=" + str(idx) + " id=" + pack_id + " file=" + name + " path=" + path)
				var result := _content_pack_loader.load_pack_data(parsed, "pack:" + name)
				if not result.ok:
					_logger.error("Content pack error " + name + ": " + str(result.error))
			else:
				_logger.error("Content pack invalid JSON: " + name)
		else:
			_logger.error("Content pack read failed: " + file_path)

func _run_minimal_example() -> void:
	pass

func _validate_no_godot_usage() -> void:
	# Runtime guard: scan core/ and game/ for banned tokens.
	var banned := [
		"extends Node",
		"\\bInput\\.",
		"\\bInputMap\\b",
		"\\bFileAccess\\b",
		"\\bResourceLoader\\b",
		"\\bOS\\.",
		"\\bEngine\\."
	]
	var paths := [
		"res://addons/rage_core/core",
		"res://addons/rage_core/game"
	]
	for base in paths:
		var files := _list_gd_files(base)
		for path in files:
			var res := _file_store.read_text(path)
			if not res.ok:
				continue
			var text: String = res.value
			for token in banned:
				if _regex_has(text, token):
					_logger.error("Forbidden token in " + path + ": " + token)
					_boot_warn("[WARN][COUPLING] rule=core_game_godot_api evidence=" + token + " path=" + path)

func _regex_has(text: String, pattern: String) -> bool:
	var re := RegEx.new()
	if re.compile(pattern) != OK:
		return false
	return re.search(text) != null

func _list_gd_files(path: String) -> Array:
	var results: Array = []
	var dir := DirAccess.open(path)
	if dir == null:
		return results
	var entries := _list_dir_entries_sorted(dir)
	for name in entries:
		var full = path + "/" + name
		if DirAccess.dir_exists_absolute(full):
			results.append_array(_list_gd_files(full))
		elif name.ends_with(".gd"):
			results.append(full)
	results.sort()
	return results

func _list_dir_entries_sorted(dir: DirAccess) -> Array:
	var names: Array = []
	dir.list_dir_begin()
	var name := dir.get_next()
	while name != "":
		if name != "." and name != "..":
			names.append(name)
		name = dir.get_next()
	dir.list_dir_end()
	names.sort()
	return names

func _resolve_boot_log_enabled() -> bool:
	if ProjectSettings.has_setting("rage_core/boot_log/enabled"):
		return bool(ProjectSettings.get_setting("rage_core/boot_log/enabled"))
	return false

func _boot_info(message: String) -> void:
	if _boot_log_enabled:
		_logger.info(message)

func _boot_warn(message: String) -> void:
	if _boot_log_enabled:
		_boot_warn_count += 1
		_logger.warn(message)

func _log_pipeline_registration() -> void:
	var ordered := _pipeline.get_ordered_steps_debug()
	_boot_system_count = ordered.size()
	_boot_info("[BOOT] stage=pipeline_registered count=" + str(_boot_system_count))
	for entry in ordered:
		var step: SimulationStep = entry["step"]
		var sys_name := _system_name(step)
		var sys_path := _system_path(step)
		var line := "[SYS] phase=" + str(entry["phase"])
		line += " priority=" + str(entry["priority"])
		line += " seq=" + str(entry["seq"])
		line += " system=" + sys_name
		line += " owner=kernel"
		if sys_path != "":
			line += " path=" + sys_path
		_boot_info(line)
	_warn_pipeline_collisions(ordered)

func _warn_pipeline_collisions(ordered: Array) -> void:
	var buckets := {}
	for entry in ordered:
		var key := str(entry["phase"]) + "|" + str(entry["priority"])
		if not buckets.has(key):
			buckets[key] = []
		buckets[key].append(_system_name(entry["step"]))
	var keys := buckets.keys()
	keys.sort()
	for key in keys:
		var systems: Array = buckets[key]
		if systems.size() > 1:
			systems.sort()
			var parts = key.split("|")
			_boot_warn("[WARN][COUPLING] rule=system_priority_collision phase=" + parts[0] + " priority=" + parts[1] + " systems=" + ",".join(systems))

func _system_name(step: SimulationStep) -> String:
	if step == null:
		return "UnknownSystem"
	return step.get_class()

func _system_path(step: SimulationStep) -> String:
	if step == null:
		return ""
	var script := step.get_script()
	if script == null:
		return ""
	return String(script.resource_path)

func _log_coupling_warnings() -> void:
	_warn_tokens_in_path("res://mods", ["\\bKernel\\b", "\\bGameKernel\\b", "/root/Kernel"], "mods_kernel_dependency")
	_warn_tokens_in_path("res://addons/rage_core/presentation", ["\\bGameState\\b", "\\bGameCore\\b", "\\bSimulationPipeline\\b"], "presentation_game_internal")

func _warn_tokens_in_path(base: String, tokens: Array, rule: String) -> void:
	var files := _list_gd_files(base)
	for path in files:
		var res := _file_store.read_text(path)
		if not res.ok:
			continue
		var text: String = res.value
		for token in tokens:
			if _regex_has(text, token):
				_boot_warn("[WARN][COUPLING] rule=" + rule + " evidence=" + token + " path=" + path)

func _build_boot_summary() -> String:
	var line := "[SUMMARY] mods=" + str(_boot_mod_count)
	line += " packs=" + str(_boot_pack_count)
	line += " systems=" + str(_boot_system_count)
	line += " warnings=" + str(_boot_warn_count)
	line += " replay_mode=" + _replay_mode
	line += " tick_rate=" + str(_tick_rate)
	line += " seed8=" + _seed8
	return line

func _bind_default_inputs() -> void:
	var binds := [
		[GameConstants.ACTION_MOVE_LEFT, "move_left"],
		[GameConstants.ACTION_MOVE_RIGHT, "move_right"],
		[GameConstants.ACTION_MOVE_UP, "move_up"],
		[GameConstants.ACTION_MOVE_DOWN, "move_down"],
		[GameConstants.ACTION_JUMP, "jump"],
		[GameConstants.ACTION_DASH, "ability_primary"]
	]
	for entry in binds:
		var res := _input_map.bind_action(entry[0], entry[1])
		if not res.ok:
			_logger.error("Input bind failed: " + str(res.error))

func _resolve_seed8() -> String:
	if _replay_mode == "replay":
		var seed_meta := String(_replay_metadata.get("seed8", ""))
		if SeedUtils.validate_seed8(seed_meta):
			return SeedUtils.normalize_seed8(seed_meta)
	var seed_value := ""
	if ProjectSettings.has_setting("rage_core/replay/seed8"):
		seed_value = String(ProjectSettings.get_setting("rage_core/replay/seed8"))
	if SeedUtils.validate_seed8(seed_value):
		return SeedUtils.normalize_seed8(seed_value)
	return _generate_seed8()

func _resolve_seed64(seed8: String) -> int:
	if _replay_mode == "replay":
		var seed64_meta := int(_replay_metadata.get("seed64", 0))
		if seed64_meta != 0:
			return seed64_meta
	return SeedUtils.seed64_from_seed8(seed8)

func _generate_seed8() -> String:
	var chars := SeedUtils.BASE36
	var out := ""
	for i in range(8):
		var idx := int(Time.get_ticks_usec() + i) % chars.length()
		out += chars[idx]
	return out

func _resolve_fixed_dt() -> float:
	var tick_rate := 60
	if _replay_mode == "replay":
		var meta_rate := int(_replay_metadata.get("tick_rate", 0))
		if meta_rate > 0:
			tick_rate = meta_rate
	elif ProjectSettings.has_setting("rage_core/replay/tick_rate"):
		tick_rate = int(ProjectSettings.get_setting("rage_core/replay/tick_rate"))
	if tick_rate <= 0:
		tick_rate = 60
	_tick_rate = tick_rate
	return 1.0 / float(tick_rate)

func _resolve_max_ticks_per_frame() -> int:
	if ProjectSettings.has_setting("rage_core/replay/max_ticks_per_frame"):
		return int(ProjectSettings.get_setting("rage_core/replay/max_ticks_per_frame"))
	return 5

func _resolve_replay_mode() -> String:
	if ProjectSettings.has_setting("rage_core/replay/mode"):
		var value := String(ProjectSettings.get_setting("rage_core/replay/mode"))
		if value == "record" or value == "replay" or value == "live":
			return value
	return "live"

func _resolve_replay_path() -> String:
	if ProjectSettings.has_setting("rage_core/replay/path"):
		return String(ProjectSettings.get_setting("rage_core/replay/path"))
	return "user://rage_replay.rage_replay.json"

func _load_replay_player() -> void:
	if _replay_mode != "replay":
		return
	var data := _read_json_file(_replay_path)
	if data.size() == 0:
		_logger.error("Replay load failed: " + _replay_path)
		return
	_replay_player = ReplayPlayer.new()
	_replay_player.load_json(data)
	_replay_metadata = _replay_player.get_metadata()
	_expected_hashes = {}
	var hashes := _replay_metadata.get("hashes", [])
	if hashes is Array:
		for entry in hashes:
			if entry is Array and entry.size() >= 2:
				_expected_hashes[int(entry[0])] = String(entry[1])

func _start_recording_if_needed() -> void:
	if _replay_mode != "record":
		return
	_replay_recorder = ReplayRecorder.new()
	var meta := _build_replay_metadata()
	_replay_recorder.start(meta, _file_store)

func _build_replay_metadata() -> Dictionary:
	var game_name := ""
	if ProjectSettings.has_setting("application/config/name"):
		game_name = String(ProjectSettings.get_setting("application/config/name"))
	return {
		"version": "1",
		"game_id": game_name,
		"seed8": _seed8,
		"seed64": _seed64,
		"tick_rate": _tick_rate,
		"mods": _loaded_mods_meta
	}

func _build_mods_meta(manifests: Array) -> Array:
	var list: Array = []
	for m in manifests:
		if m is ModManifest:
			list.append([m.id, m.version])
	list.sort_custom(func(a, b):
		if a[0] == b[0]:
			return false
		return String(a[0]) < String(b[0])
	)
	return list

func _get_snapshot_for_tick() -> InputSnapshot:
	if _replay_mode == "replay":
		if _replay_player == null:
			return null
		var frame := _replay_player.get_frame(_tick_index)
		if frame == null:
			_logger.error("Replay frame missing at tick " + str(_tick_index))
			set_process(false)
			return null
		return _replay_player.build_snapshot(frame, _input_registry)
	var source: IInputSource = _input
	if _input_override != null:
		source = _input_override
		if _input_override.has_method("set_tick"):
			_input_override.call("set_tick", _tick_index)
	return _api.sample_input(source)

func _handle_post_tick(snapshot: InputSnapshot) -> void:
	if _replay_mode == "record":
		if _replay_recorder != null:
			_replay_recorder.record_frame(snapshot, _tick_index)
		var hash := StateHasher.hash_canonical_state(_state.export_canonical())
		_hash_log.append([_tick_index, hash])
	if _replay_mode == "replay":
		var expected := String(_expected_hashes.get(_tick_index, ""))
		if expected != "":
			var current := StateHasher.hash_canonical_state(_state.export_canonical())
			if current != expected:
				_logger.error("Replay desync at tick " + str(_tick_index))
				_dump_desync_state(_tick_index)
				set_process(false)

func _dump_desync_state(tick_index: int) -> void:
	var data := _state.export_canonical()
	var path := "user://rage_desync_tick_" + str(tick_index) + ".json"
	_write_json_file(path, data)

func _read_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	var parsed = JSON.parse_string(text)
	if parsed == null or not (parsed is Dictionary):
		return {}
	return parsed

func _write_json_file(path: String, data: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	return true

func _exit_tree() -> void:
	if _replay_mode != "record" or _replay_recorder == null:
		return
	_replay_recorder.set_hashes(_hash_log)
	_replay_recorder.stop()
	_replay_recorder.save_json(_replay_path)
