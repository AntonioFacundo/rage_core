# Game: Deterministic room combat placeholder. Allowed deps: core types only.
class_name RoomCombatSystem
extends SimulationStep

var _run_state: RunState

func _init(run_state: RunState) -> void:
	_run_state = run_state

func run(context: SimulationContext, _delta: float) -> void:
	if _run_state == null or context == null:
		return
	if not _run_state.is_run_active():
		return
	var stage := _run_state.get_tower_stage()
	if stage == "boss":
		_run_boss_combat(context)
		return
	if not _run_state.is_room_combat_active():
		return

	var room_id := _run_state.get_room_id()
	if room_id == "":
		return

	if not _run_state.is_room_combat_started():
		var starting_remaining := _run_state.get_room_enemies_remaining()
		_run_state.set_room_combat_started(true)
		context.logger.info("[COMBAT] start room=" + room_id + " enemies=" + str(starting_remaining))
		if starting_remaining <= 0:
			_run_state.set_room_combat_active(false)
			_run_state.set_room_status("cleared")
			context.logger.info("[COMBAT] cleared room=" + room_id)
		return

	var remaining := _run_state.get_room_enemies_remaining()
	if remaining <= 0:
		return
	remaining -= 1
	_run_state.set_room_enemies_remaining(remaining)
	var hit := _apply_enemy_hit()
	if hit and context != null:
		context.logger.info("[HP] damage source=enemy amount=1 health=" + str(_run_state.get_run_health()))
		if _run_state.get_run_health() <= 0:
			_run_state.end_run("health_zero")
			return
	context.logger.info("[COMBAT] tick room=" + room_id + " enemies_remaining=" + str(remaining))

	if remaining <= 0:
		_run_state.set_room_status("cleared")
		context.logger.info("[COMBAT] cleared room=" + room_id)
		return

func _run_boss_combat(context: SimulationContext) -> void:
	if _run_state.get_boss_status() != "active":
		return
	var boss_remaining := _run_state.get_boss_remaining()
	if boss_remaining <= 0:
		return
	boss_remaining -= 1
	_run_state.set_boss_remaining(boss_remaining)
	var hit := _apply_boss_hit()
	if hit and context != null:
		context.logger.info("[HP] damage source=enemy amount=1 health=" + str(_run_state.get_run_health()))
		if _run_state.get_run_health() <= 0:
			_run_state.end_run("health_zero")
			return
	context.logger.info("[BOSS] tick remaining=" + str(boss_remaining))
	if boss_remaining <= 0:
		_run_state.set_boss_status("defeated")
		context.logger.info("[BOSS] defeated")

func _apply_enemy_hit() -> bool:
	var rng := DeterministicRng.new()
	var hit_seed := _hit_seed(_run_state.get_seed64(), _run_state.get_stage_index(), _run_state.get_room_enemies_remaining())
	rng.seed(hit_seed)
	var hit := rng.range_int(1, 4) == 1
	if hit:
		_run_state.add_run_health(-1)
	return hit

func _apply_boss_hit() -> bool:
	var rng := DeterministicRng.new()
	var hit_seed := _hit_seed(_run_state.get_seed64(), _run_state.get_stage_index(), _run_state.get_boss_remaining())
	rng.seed(hit_seed)
	var hit := rng.range_int(1, 10) == 1
	if hit:
		_run_state.add_run_health(-1)
	return hit

func _hit_seed(seed64: int, stage_index: int, remaining: int) -> int:
	var text := "enemy_hit|" + str(seed64) + "|" + str(stage_index) + "|" + str(remaining)
	return Fnv1a64.hash_string(text)
