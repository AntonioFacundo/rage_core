# Game: Deterministic run state container. Allowed deps: core types only.
class_name RunState

var _tick: int = 0
var _currency: int = 0
var _abilities: Array = []
var _stage_index: int = 0
var _room_id: String = ""
var _wave_id: String = ""
var _room_status: String = ""
var _room_enemies_remaining: int = 0
var _room_enemies_defeated: int = 0
var _room_enemies_total: int = 0
var _room_combat_active: bool = false
var _room_combat_started: bool = false
var _room_limit: int = 10
var _shop_active: bool = false
var _shop_ready: bool = false
var _shop_resolved: bool = false
var _shop_offers: Array = []
var _shop_health_pickups: int = 0
var _shop_last_room_index: int = -1
var _last_ability_room_index: int = -1
var _gate_active: bool = false
var _gate_status: String = "inactive"
var _gate_last_room_index: int = -1
var _gate_retry_ticks: int = 0
var _tower_stage: String = "rooms"
var _boss_status: String = "inactive"
var _boss_remaining: int = 0
var _reward_recorded: bool = false
var _reward_npc_id: String = ""
var _reward_leaf_id: String = ""
var _damage_mult_bp: int = 100
var _drop_mult_bp: int = 100
var _run_health: int = 10
var _run_active: bool = true
var _end_reason: String = ""
var _run_end_reason: String = ""
var _run_end_data: Dictionary = {}
var _run_end_pending_reset: bool = false
var _seed64: int = 0

func reset(new_seed64: int) -> void:
	_seed64 = new_seed64
	_tick = 0
	_currency = 0
	_abilities.clear()
	_stage_index = 0
	_room_id = ""
	_wave_id = ""
	_room_status = ""
	_room_enemies_remaining = 0
	_room_enemies_defeated = 0
	_room_enemies_total = 0
	_room_combat_active = false
	_room_combat_started = false
	_room_limit = 10
	_shop_active = false
	_shop_ready = false
	_shop_resolved = false
	_shop_offers.clear()
	_shop_health_pickups = 0
	_shop_last_room_index = -1
	_last_ability_room_index = -1
	_gate_active = false
	_gate_status = "inactive"
	_gate_last_room_index = -1
	_gate_retry_ticks = 0
	_tower_stage = "rooms"
	_boss_status = "inactive"
	_boss_remaining = 0
	_reward_recorded = false
	_reward_npc_id = ""
	_reward_leaf_id = ""
	_damage_mult_bp = 100
	_drop_mult_bp = 100
	_run_health = 10
	_run_active = true
	_end_reason = ""
	_run_end_reason = ""
	_run_end_data.clear()
	_run_end_pending_reset = false

func get_tick() -> int:
	return _tick

func set_tick(value: int) -> void:
	_tick = value

func add_currency(amount: int) -> void:
	if amount > 0:
		_currency += amount

func spend_currency(amount: int) -> bool:
	if amount <= 0:
		return false
	if _currency < amount:
		return false
	_currency -= amount
	return true

func get_currency() -> int:
	return _currency

func add_ability(ability_id: String) -> bool:
	if _abilities.has(ability_id):
		return false
	_abilities.append(ability_id)
	return true

func has_ability(ability_id: String) -> bool:
	return _abilities.has(ability_id)

func list_abilities() -> Array:
	return _abilities.duplicate()

func set_stage_index(value: int) -> void:
	_stage_index = value

func get_stage_index() -> int:
	return _stage_index

func set_room_id(value: String) -> void:
	_room_id = value

func get_room_id() -> String:
	return _room_id

func set_wave_id(value: String) -> void:
	_wave_id = value

func get_wave_id() -> String:
	return _wave_id

func set_room_status(value: String) -> void:
	_room_status = value

func get_room_status() -> String:
	return _room_status

func set_room_enemies_remaining(value: int) -> void:
	_room_enemies_remaining = max(0, value)

func get_room_enemies_remaining() -> int:
	return _room_enemies_remaining

func set_room_enemies_defeated(value: int) -> void:
	_room_enemies_defeated = max(0, value)

func get_room_enemies_defeated() -> int:
	return _room_enemies_defeated

func set_room_enemies_total(value: int) -> void:
	_room_enemies_total = max(0, value)

func get_room_enemies_total() -> int:
	return _room_enemies_total

func set_room_combat_active(value: bool) -> void:
	_room_combat_active = value

func is_room_combat_active() -> bool:
	return _room_combat_active

func set_room_combat_started(value: bool) -> void:
	_room_combat_started = value

func is_room_combat_started() -> bool:
	return _room_combat_started

func set_room_limit(value: int) -> void:
	if value > 0:
		_room_limit = value

func get_room_limit() -> int:
	return _room_limit

func set_shop_active(value: bool) -> void:
	_shop_active = value

func is_shop_active() -> bool:
	return _shop_active

func set_shop_ready(value: bool) -> void:
	_shop_ready = value

func is_shop_ready() -> bool:
	return _shop_ready

func set_shop_resolved(value: bool) -> void:
	_shop_resolved = value

func is_shop_resolved() -> bool:
	return _shop_resolved

func set_shop_offers(value: Array) -> void:
	_shop_offers = value.duplicate()

func list_shop_offers() -> Array:
	return _shop_offers.duplicate()

func clear_shop_offers() -> void:
	_shop_offers.clear()

func set_shop_health_pickups(value: int) -> void:
	_shop_health_pickups = max(0, value)

func get_shop_health_pickups() -> int:
	return _shop_health_pickups

func set_shop_last_room_index(value: int) -> void:
	_shop_last_room_index = value

func get_shop_last_room_index() -> int:
	return _shop_last_room_index

func set_last_ability_room_index(value: int) -> void:
	_last_ability_room_index = value

func get_last_ability_room_index() -> int:
	return _last_ability_room_index

func set_gate_active(value: bool) -> void:
	_gate_active = value

func is_gate_active() -> bool:
	return _gate_active

func set_gate_status(value: String) -> void:
	_gate_status = value

func get_gate_status() -> String:
	return _gate_status

func set_gate_last_room_index(value: int) -> void:
	_gate_last_room_index = value

func get_gate_last_room_index() -> int:
	return _gate_last_room_index

func set_gate_retry_ticks(value: int) -> void:
	_gate_retry_ticks = max(0, value)

func get_gate_retry_ticks() -> int:
	return _gate_retry_ticks

func set_tower_stage(value: String) -> void:
	_tower_stage = value

func get_tower_stage() -> String:
	return _tower_stage

func set_boss_status(value: String) -> void:
	_boss_status = value

func get_boss_status() -> String:
	return _boss_status

func set_boss_remaining(value: int) -> void:
	_boss_remaining = max(0, value)

func get_boss_remaining() -> int:
	return _boss_remaining

func set_reward_recorded(value: bool) -> void:
	_reward_recorded = value

func is_reward_recorded() -> bool:
	return _reward_recorded

func set_reward_npc_id(value: String) -> void:
	_reward_npc_id = value

func get_reward_npc_id() -> String:
	return _reward_npc_id

func set_reward_leaf_id(value: String) -> void:
	_reward_leaf_id = value

func get_reward_leaf_id() -> String:
	return _reward_leaf_id

func add_damage_mult_bp(value: int) -> void:
	_damage_mult_bp = max(0, _damage_mult_bp + value)

func get_damage_mult_bp() -> int:
	return _damage_mult_bp

func add_drop_mult_bp(value: int) -> void:
	_drop_mult_bp = max(0, _drop_mult_bp + value)

func get_drop_mult_bp() -> int:
	return _drop_mult_bp

func add_run_health(value: int) -> void:
	_run_health = max(0, _run_health + value)

func get_run_health() -> int:
	return _run_health

func end_run(reason: String) -> void:
	_run_active = false
	_end_reason = reason

func set_run_end_reason(value: String) -> void:
	_run_end_reason = value

func get_run_end_reason() -> String:
	return _run_end_reason

func set_run_end_data(value: Dictionary) -> void:
	_run_end_data = value.duplicate(true)

func get_run_end_data() -> Dictionary:
	return _run_end_data.duplicate(true)

func set_run_end_pending_reset(value: bool) -> void:
	_run_end_pending_reset = value

func is_run_end_pending_reset() -> bool:
	return _run_end_pending_reset

func is_run_active() -> bool:
	return _run_active

func get_end_reason() -> String:
	return _end_reason

func get_seed64() -> int:
	return _seed64

func export_canonical() -> Dictionary:
	return {
		"seed64": _seed64,
		"tick": _tick,
		"currency": _currency,
		"abilities": list_abilities(),
		"stage_index": _stage_index,
		"room_id": _room_id,
		"wave_id": _wave_id,
		"room_status": _room_status,
		"room_enemies_remaining": _room_enemies_remaining,
		"room_enemies_defeated": _room_enemies_defeated,
		"room_enemies_total": _room_enemies_total,
		"room_combat_active": _room_combat_active,
		"room_combat_started": _room_combat_started,
		"room_limit": _room_limit,
		"shop_active": _shop_active,
		"shop_ready": _shop_ready,
		"shop_resolved": _shop_resolved,
		"shop_offers": list_shop_offers(),
		"shop_health_pickups": _shop_health_pickups,
		"shop_last_room_index": _shop_last_room_index,
		"last_ability_room_index": _last_ability_room_index,
		"gate_active": _gate_active,
		"gate_status": _gate_status,
		"gate_last_room_index": _gate_last_room_index,
		"gate_retry_ticks": _gate_retry_ticks,
		"tower_stage": _tower_stage,
		"boss_status": _boss_status,
		"boss_remaining": _boss_remaining,
		"reward_recorded": _reward_recorded,
		"reward_npc_id": _reward_npc_id,
		"reward_leaf_id": _reward_leaf_id,
		"damage_mult_bp": _damage_mult_bp,
		"drop_mult_bp": _drop_mult_bp,
		"run_health": _run_health,
		"run_end_reason": _run_end_reason,
		"run_end_data": get_run_end_data(),
		"run_end_pending_reset": _run_end_pending_reset,
		"run_active": _run_active,
		"end_reason": _end_reason
	}
