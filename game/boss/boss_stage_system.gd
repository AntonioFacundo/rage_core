# Game: Deterministic boss stage transition. Allowed deps: core types only.
class_name BossStageSystem
extends SimulationStep

const BOSS_TICKS := 10

var _run_state: RunState

func _init(run_state: RunState) -> void:
	_run_state = run_state

func run(context: SimulationContext, _delta: float) -> void:
	if _run_state == null or context == null:
		return
	if not _run_state.is_run_active():
		return
	if _run_state.get_tower_stage() != "rooms":
		return
	if _run_state.get_gate_status() != "passed":
		return

	_run_state.set_tower_stage("boss")
	_run_state.set_room_status("boss")
	_run_state.set_boss_status("active")
	_run_state.set_boss_remaining(BOSS_TICKS)
	_run_state.set_gate_active(false)
	_run_state.set_gate_retry_ticks(0)
	context.logger.info("[BOSS] enter")
	context.logger.info("[BOSS] start remaining=" + str(BOSS_TICKS))
