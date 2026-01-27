# Game: Deterministic room economy placeholder. Allowed deps: core types only.
class_name RoomEconomySystem
extends SimulationStep

const DROP_MIN := 3
const DROP_MAX := 10

var _run_state: RunState

func _init(run_state: RunState) -> void:
	_run_state = run_state

func run(context: SimulationContext, _delta: float) -> void:
	if _run_state == null or context == null:
		return
	if not _run_state.is_run_active():
		return
	if not _run_state.is_room_combat_active():
		return

	var total := _run_state.get_room_enemies_total()
	if total <= 0:
		return
	var remaining := _run_state.get_room_enemies_remaining()
	var defeated := _run_state.get_room_enemies_defeated()
	var expected_defeated = max(0, total - remaining)

	if defeated >= expected_defeated:
		return

	var rng := DeterministicRng.new()
	var drop_seed := _drop_seed(_run_state.get_seed64(), _run_state.get_stage_index(), defeated)
	rng.seed(drop_seed)
	var value := rng.range_int(DROP_MIN, DROP_MAX)
	_run_state.add_currency(value)
	defeated += 1
	_run_state.set_room_enemies_defeated(defeated)

	context.logger.info("[DROP] enemy_defeated value=" + str(value))
	context.logger.info("[ECON] currency_total=" + str(_run_state.get_currency()))

	if defeated >= total:
		_run_state.set_room_combat_active(false)

func _drop_seed(seed64: int, stage_index: int, defeated_index: int) -> int:
	var text := "drop|" + str(seed64) + "|" + str(stage_index) + "|" + str(defeated_index)
	return Fnv1a64.hash_string(text)
