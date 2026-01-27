# Game Tests: Engine-agnostic verification for game systems and registries.
class_name GameTestRunner

static func run_all() -> Dictionary:
	var errors: Array = []
	var total := 0
	_test_input_registry_order(errors)
	total += 1
	_test_content_registry_order(errors)
	total += 2
	_test_pipeline_order(errors)
	total += 2
	_test_content_pack_loader(errors)
	total += 3
	_test_game_core_commands(errors)
	total += 4
	_test_replay_roundtrip(errors)
	total += 4
	_test_game_api_apply_command(errors)
	total += 2
	return {
		"errors": errors,
		"total": total
	}

static func _test_input_registry_order(errors: Array) -> void:
	var registry := InputRegistry.new()
	registry.register_action("action.zzz")
	registry.register_action("action.aaa")
	var actions := registry.list_actions()
	var sorted := actions.duplicate()
	sorted.sort()
	_assert(actions == sorted, "InputRegistry.list_actions should be sorted", errors)

static func _test_content_registry_order(errors: Array) -> void:
	var registry := ContentRegistry.new()
	var def_b := ContentDef.new("b", GameConstants.CONTENT_PICKUP, {}, "test")
	var def_a := ContentDef.new("a", GameConstants.CONTENT_PICKUP, {}, "test")
	registry.register(def_b)
	registry.register(def_a)
	var list := registry.list_by_type(GameConstants.CONTENT_PICKUP)
	_assert(list.size() == 2, "ContentRegistry.list_by_type should return items", errors)
	if list.size() >= 2:
		_assert(list[0].id == "a" and list[1].id == "b", "ContentRegistry.list_by_type should be sorted by id", errors)

static func _test_pipeline_order(errors: Array) -> void:
	var pipeline := SimulationPipeline.new()
	var step_a := _TestStep.new("a")
	var step_b := _TestStep.new("b")
	var step_c := _TestStep.new("c")
	pipeline.register_step(GameConstants.PHASE_INPUT, 5, step_a)
	pipeline.register_step(GameConstants.PHASE_INPUT, 5, step_b)
	pipeline.register_step(GameConstants.PHASE_MOVEMENT, 10, step_c)
	var ordered := pipeline.get_ordered_steps_debug()
	var ids: Array = []
	for entry in ordered:
		var step: _TestStep = entry["step"]
		ids.append(step.id)
	_assert(ids.size() == 3, "SimulationPipeline should return 3 steps", errors)
	if ids.size() >= 3:
		_assert(ids[0] == "a" and ids[1] == "b" and ids[2] == "c", "SimulationPipeline order should be phase then seq", errors)

static func _test_content_pack_loader(errors: Array) -> void:
	var registry := ContentRegistry.new()
	var loader := ContentPackLoader.new(registry)
	var pack_ok: Dictionary = {
		"contents": [
			{"id": "room.a", "type": GameConstants.CONTENT_ROOM, "data": {"tier": 1}}
		]
	}
	var res_ok = loader.load_pack_data(pack_ok, "mod.test")
	_assert(res_ok.ok, "ContentPackLoader should accept valid content entries", errors)
	var def_ok := registry.get_by_id("room.a")
	_assert(def_ok != null and def_ok.source_mod == "mod.test", "ContentPackLoader should register content defs", errors)

	var pack_missing_id: Dictionary = {
		"contents": [
			{"type": GameConstants.CONTENT_ROOM, "data": {}}
		]
	}
	var res_missing_id = loader.load_pack_data(pack_missing_id, "mod.test")
	_assert(not res_missing_id.ok, "ContentPackLoader should reject entries missing id", errors)

	var pack_bad_data: Dictionary = {
		"contents": [
			{"id": "room.b", "type": GameConstants.CONTENT_ROOM, "data": "bad"}
		]
	}
	var res_bad_data = loader.load_pack_data(pack_bad_data, "mod.test")
	_assert(not res_bad_data.ok, "ContentPackLoader should reject non-dictionary data", errors)

static func _test_game_core_commands(errors: Array) -> void:
	var bus := EventBus.new()
	var state := GameState.new()
	var logger := _TestLogger.new()
	var rng := DeterministicRng.new()
	rng.seed(1)
	var core := GameCore.new(bus, state, logger, rng)

	state.set_health("target", 10)
	var cmd := AttackCommand.new("attacker", "target", 3)
	var res = core.apply_command(cmd)
	_assert(res.ok, "GameCore.apply_command should accept AttackCommand", errors)
	_assert(state.get_health("target") == 7, "AttackCommand should reduce health", errors)

	state.set_health("target", 5)
	var bad_cmd := AttackCommand.new("attacker", "target", 0)
	var res_bad = core.apply_command(bad_cmd)
	_assert(not res_bad.ok, "Invalid AttackCommand should fail validation", errors)
	_assert(state.get_health("target") == 5, "Invalid command should not change state", errors)

	var unknown_cmd := _TestCommand.new("cmd.unknown")
	var res_unknown = core.apply_command(unknown_cmd)
	_assert(not res_unknown.ok, "Unknown command should be rejected", errors)

static func _test_replay_roundtrip(errors: Array) -> void:
	var registry := InputRegistry.new()
	registry.register_action("action.b")
	registry.register_action("action.a")
	registry.register_axis("axis.y")
	registry.register_axis("axis.x")
	var pressed: Dictionary = {"action.b": true, "action.a": false}
	var just_pressed: Dictionary = {"action.b": true, "action.a": false}
	var axes: Dictionary = {"axis.x": 0.5, "axis.y": -1.0}
	var snapshot := InputSnapshot.new(pressed, just_pressed, axes)

	var recorder := ReplayRecorder.new()
	var store := _MemFileStore.new()
	recorder.start({"seed": 1}, store)
	recorder.record_frame(snapshot, 0)
	var stream := recorder.stop()
	_assert(stream.frames.size() == 1, "ReplayRecorder should store frames", errors)
	var save_res = recorder.save_json("mem://replay.json")
	_assert(save_res.ok and store.has_path("mem://replay.json"), "ReplayRecorder should save via IFileStore", errors)

	var frame = stream.get_frame(0)
	_assert(frame != null, "ReplayStream.get_frame should return a frame by tick", errors)

	var player := ReplayPlayer.new()
	var snap := player.build_snapshot(frame, registry)
	_assert(snap.is_pressed("action.b") and not snap.is_pressed("action.a"), "ReplayPlayer should restore pressed actions", errors)
	_assert(snap.is_just_pressed("action.b"), "ReplayPlayer should compute just_pressed", errors)

static func _test_game_api_apply_command(errors: Array) -> void:
	var bus := EventBus.new()
	var state := GameState.new()
	var logger := _TestLogger.new()
	var rng := DeterministicRng.new()
	rng.seed(2)
	var core := GameCore.new(bus, state, logger, rng)
	var registry := InputRegistry.new()
	var input_map := GameInputMap.new(registry)
	var content_registry := ContentRegistry.new()
	var save_store := _TestSaveStore.new()
	var save_manager := SaveManager.new(save_store, logger)
	var api := GameAPI.new(
		bus,
		core,
		state,
		state.view(),
		logger,
		_TestClock.new(),
		registry,
		input_map,
		content_registry,
		save_store,
		save_manager
	)
	state.set_health("target", 4)
	var cmd := AttackCommand.new("attacker", "target", 2)
	var res = api.apply_command(cmd)
	_assert(res.ok and state.get_health("target") == 2, "GameAPI.apply_command should pass through to core", errors)
	var res_unknown = api.apply_command(_TestCommand.new("cmd.unknown"))
	_assert(not res_unknown.ok, "GameAPI.apply_command should reject unknown commands", errors)

static func _assert(condition: bool, message: String, errors: Array) -> void:
	if not condition:
		errors.append(message)

class _TestStep:
	extends SimulationStep
	var id: String
	func _init(step_id: String) -> void:
		id = step_id

class _TestCommand:
	extends ICommand
	var _id: String
	func _init(command_id: String) -> void:
		_id = command_id
	func get_id() -> String:
		return _id
	func validate() -> Result:
		return Result.ok_result(true)

class _TestLogger:
	extends ILogger
	func info(_message: String) -> void:
		pass
	func warn(_message: String) -> void:
		pass
	func error(_message: String) -> void:
		pass

class _TestClock:
	extends IClock
	func now_msec() -> int:
		return 0

class _TestSaveStore:
	extends ISaveStore
	var _data := {}
	func save_json(key: String, data: Dictionary) -> Result:
		_data[key] = data
		return Result.ok_result(true)
	func load_json(key: String) -> Result:
		if not _data.has(key):
			return Result.err_result("missing key")
		return Result.ok_result(_data[key])
	func delete(key: String) -> Result:
		if _data.has(key):
			_data.erase(key)
		return Result.ok_result(true)

class _MemFileStore:
	extends IFileStore
	var _files := {}
	func exists(path: String) -> bool:
		return _files.has(path)
	func read_text(path: String) -> Result:
		if not _files.has(path):
			return Result.err_result("missing path")
		return Result.ok_result(_files[path])
	func write_text(path: String, content: String) -> Result:
		_files[path] = content
		return Result.ok_result(true)
	func has_path(path: String) -> bool:
		return _files.has(path)
