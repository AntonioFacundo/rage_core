# Game: Deterministic ability awards per run. Allowed deps: core types only.
class_name AbilityAwardSystem
extends SimulationStep

const ABILITIES := ["dash", "double_jump", "wall_jump"]
const ROOMS_PER_AWARD := 3

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

	if _run_state.get_room_status() != "cleared":
		return

	var room_index := _run_state.get_stage_index()
	if _run_state.get_last_ability_room_index() == room_index:
		return

	if not _should_award(room_index):
		return

	var next_id := _next_missing_ability()
	if next_id == "":
		return

	if _run_state.add_ability(next_id):
		_run_state.set_last_ability_room_index(room_index)
		context.logger.info("[ABIL] grant id=" + next_id + " at_room_index=" + str(room_index))
		context.logger.info("[ABIL] current=" + str(_run_state.list_abilities()))

func _should_award(room_index: int) -> bool:
	if room_index < 0:
		return false
	return ((room_index + 1) % ROOMS_PER_AWARD) == 0

func _next_missing_ability() -> String:
	for ability_id in ABILITIES:
		if not _run_state.has_ability(ability_id):
			return ability_id
	return ""
