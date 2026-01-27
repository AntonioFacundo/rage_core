# Game: Deterministic parkour gate check. Allowed deps: core types only.
class_name ParkourGateSystem
extends SimulationStep

const GATE_ROOM_INDEX := 8
const REQUIRED_ABILITIES := ["dash", "double_jump", "wall_jump"]
const RETRY_TICKS := 10

var _run_state: RunState

func _init(run_state: RunState) -> void:
	_run_state = run_state

func run(context: SimulationContext, _delta: float) -> void:
	if _run_state == null or context == null:
		return
	if not _run_state.is_run_active():
		return
	if _run_state.is_shop_active():
		return
	if _run_state.get_tower_stage() != "rooms":
		return

	var status := _run_state.get_room_status()
	if status != "cleared":
		return

	var room_index := _run_state.get_stage_index()
	if room_index != GATE_ROOM_INDEX:
		return

	if _run_state.get_gate_last_room_index() == room_index and _run_state.get_gate_status() == "passed":
		return

	_run_state.set_gate_active(true)
	if _run_state.get_gate_status() == "inactive":
		context.logger.info("[GATE] open at_room_index=" + str(room_index))

	var retry_ticks := _run_state.get_gate_retry_ticks()
	if retry_ticks > 0:
		_run_state.set_gate_retry_ticks(retry_ticks - 1)
		return

	var missing := _first_missing_ability()
	context.logger.info("[GATE] check required=" + str(REQUIRED_ABILITIES) + " current=" + str(_run_state.list_abilities()))
	if missing == "":
		_run_state.set_gate_status("passed")
		_run_state.set_gate_active(false)
		_run_state.set_gate_last_room_index(room_index)
		_run_state.set_gate_retry_ticks(0)
		context.logger.info("[GATE] result=PASSED")
		return

	_run_state.set_gate_status("failed")
	_run_state.add_run_health(-1)
	_run_state.set_gate_retry_ticks(RETRY_TICKS)
	context.logger.info("[GATE] result=FAILED reason=missing_" + missing)
	context.logger.info("[HP] damage source=gate amount=1 health=" + str(_run_state.get_run_health()))

	if _run_state.get_run_health() <= 0:
		_run_state.end_run("gate_failed")
		context.logger.info("[RUN] end reason=gate_failed")
		return

func _first_missing_ability() -> String:
	for ability_id in REQUIRED_ABILITIES:
		if not _run_state.has_ability(ability_id):
			return ability_id
	return ""
