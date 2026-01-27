# Game: Deterministic level selection step. Allowed deps: core types only.
# Pulls ContentDefs from SimulationContext.content_registry.
class_name LevelSelectionSystem
extends SimulationStep

var _run_state: RunState
var _selector: LevelSelector

func _init(run_state: RunState, selector: LevelSelector) -> void:
	_run_state = run_state
	_selector = selector

func run(context: SimulationContext, _delta: float) -> void:
	if _run_state == null or _selector == null or context == null:
		return
	var registry: ContentRegistry = context.content_registry
	if registry == null:
		return
	if not _run_state.is_run_active():
		return
	if _run_state.is_shop_active():
		return
	if _run_state.is_gate_active():
		return
	if _run_state.get_tower_stage() != "rooms":
		return
	var stage_index := _run_state.get_stage_index()
	var room_limit := _run_state.get_room_limit()
	if stage_index >= room_limit:
		_run_state.end_run("room_limit")
		context.logger.info("[RUN] end reason=room_limit")
		return

	var room_id := _run_state.get_room_id()
	var status := _run_state.get_room_status()
	if room_id == "":
		var room := _selector.select_next_room(_run_state, registry, {})
		if room == null:
			_run_state.end_run("no_rooms")
			context.logger.info("[RUN] end reason=no_rooms")
			return
		var wave := _selector.select_wave_for_room(_run_state, registry, room, {})
		var enemies := _count_enemies_from_wave(wave)
		_run_state.set_room_id(room.id)
		_run_state.set_wave_id(wave.id if wave != null else "")
		_run_state.set_room_status("combat")
		_run_state.set_room_enemies_remaining(enemies)
		_run_state.set_room_enemies_defeated(0)
		_run_state.set_room_enemies_total(enemies)
		_run_state.set_room_combat_active(true)
		_run_state.set_room_combat_started(false)
		context.logger.info("[LEVEL] enter room=" + room.id + " index=" + str(stage_index))
		return

	if status == "combat":
		return

	if status == "cleared":
		var next_index := stage_index + 1
		if next_index >= room_limit:
			_run_state.end_run("room_limit")
			context.logger.info("[RUN] end reason=room_limit")
			return
		_run_state.set_stage_index(next_index)
		var next_room := _selector.select_next_room(_run_state, registry, {})
		if next_room == null:
			_run_state.end_run("no_rooms")
			context.logger.info("[RUN] end reason=no_rooms")
			return
		var next_wave := _selector.select_wave_for_room(_run_state, registry, next_room, {})
		var next_enemies := _count_enemies_from_wave(next_wave)
		_run_state.set_room_id(next_room.id)
		_run_state.set_wave_id(next_wave.id if next_wave != null else "")
		_run_state.set_room_status("combat")
		_run_state.set_room_enemies_remaining(next_enemies)
		_run_state.set_room_enemies_defeated(0)
		_run_state.set_room_enemies_total(next_enemies)
		_run_state.set_room_combat_active(true)
		_run_state.set_room_combat_started(false)
		context.logger.info("[LEVEL] next room=" + next_room.id)
		context.logger.info("[LEVEL] enter room=" + next_room.id + " index=" + str(next_index))
		return

	_run_state.set_room_status("combat")
	context.logger.info("[LEVEL] enter room=" + room_id + " index=" + str(stage_index))

func _count_enemies_from_wave(wave: ContentDef) -> int:
	if wave == null:
		return 0
	var data = wave.data
	if not (data is Dictionary):
		return 0
	var spawns = data.get("spawns", [])
	if not (spawns is Array):
		return 0
	var total := 0
	for entry in spawns:
		if entry is Dictionary:
			total += max(0, int(entry.get("count", 0)))
	return total
