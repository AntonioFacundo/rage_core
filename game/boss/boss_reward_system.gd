# Game: Deterministic boss reward and victory. Allowed deps: core types only.
class_name BossRewardSystem
extends SimulationStep

const NPC_IDS := ["madman", "merchant", "villager"]
const LEAF_IDS := ["leaf.red", "leaf.blue", "leaf.gold"]

var _run_state: RunState

func _init(run_state: RunState) -> void:
	_run_state = run_state

func run(context: SimulationContext, _delta: float) -> void:
	if _run_state == null or context == null:
		return
	if not _run_state.is_run_active():
		return
	if _run_state.get_tower_stage() != "boss":
		return
	if _run_state.get_boss_status() != "defeated":
		return
	if _run_state.is_reward_recorded():
		return

	var npc_id := _pick_from(NPC_IDS, "npc")
	var leaf_id := _pick_from(LEAF_IDS, "leaf")
	_run_state.set_reward_npc_id(npc_id)
	_run_state.set_reward_leaf_id(leaf_id)
	_run_state.set_reward_recorded(true)
	context.logger.info("[REWARD] leaf npc=" + npc_id + " leaf=" + leaf_id)

	_run_state.end_run("victory")

func _pick_from(list: Array, salt: String) -> String:
	if list.size() == 0:
		return ""
	var rng := DeterministicRng.new()
	var reward_seed := _reward_seed(_run_state.get_seed64(), salt)
	rng.seed(reward_seed)
	var idx := rng.range_int(0, list.size() - 1)
	return String(list[idx])

func _reward_seed(seed64: int, salt: String) -> int:
	var text := "boss_reward|" + salt + "|" + str(seed64)
	return Fnv1a64.hash_string(text)
