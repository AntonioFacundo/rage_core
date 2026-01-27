# Game: Deterministic shop offer generator. Allowed deps: core types only.
class_name ShopOfferSystem
extends SimulationStep

const OFFER_COUNT := 3
const HEALTH_PICKUP_MAX := 3

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

	var stage_index := _run_state.get_stage_index()
	if stage_index < 0:
		return
	if ((stage_index + 1) % 2) != 0:
		return
	if _run_state.get_shop_last_room_index() == stage_index:
		return

	var offers := _build_offers(stage_index)
	var health_pickups := _roll_health_pickups(stage_index)

	_run_state.set_shop_offers(offers)
	_run_state.set_shop_health_pickups(health_pickups)
	_run_state.set_shop_active(true)
	_run_state.set_shop_ready(false)
	_run_state.set_shop_resolved(false)
	_run_state.set_shop_last_room_index(stage_index)

	context.logger.info("[SHOP] open offers=" + _format_offers(offers) + " health_pickups=" + str(health_pickups))

func _build_offers(stage_index: int) -> Array:
	var types := ["damage", "drops", "damage"]
	var offers: Array = []
	for i in range(OFFER_COUNT):
		var offer_type = types[i]
		var tier := _roll_tier(stage_index, i)
		var cost := 5 + (tier * 5)
		var effect := _build_effect(offer_type, tier)
		offers.append({
			"id": "shop." + offer_type + ".t" + str(tier),
			"type": offer_type,
			"tier": tier,
			"cost": cost,
			"effect": effect
		})
	return offers

func _build_effect(offer_type: String, tier: int) -> Dictionary:
	if offer_type == "damage":
		return { "type": "damage_mult_bp", "value": tier * 10 }
	if offer_type == "drops":
		return { "type": "drop_mult_bp", "value": tier * 15 }
	return { "type": "none", "value": 0 }

func _roll_tier(stage_index: int, offer_index: int) -> int:
	var rng := DeterministicRng.new()
	var offer_seed := _offer_seed(_run_state.get_seed64(), stage_index, offer_index)
	rng.seed(offer_seed)
	return rng.range_int(0, 3)

func _roll_health_pickups(stage_index: int) -> int:
	var rng := DeterministicRng.new()
	var health_seed := _health_seed(_run_state.get_seed64(), stage_index)
	rng.seed(health_seed)
	return rng.range_int(0, HEALTH_PICKUP_MAX)

func _offer_seed(seed64: int, stage_index: int, offer_index: int) -> int:
	var text := "shop_offer|" + str(seed64) + "|" + str(stage_index) + "|" + str(offer_index)
	return Fnv1a64.hash_string(text)

func _health_seed(seed64: int, stage_index: int) -> int:
	var text := "shop_health|" + str(seed64) + "|" + str(stage_index)
	return Fnv1a64.hash_string(text)

func _format_offers(offers: Array) -> String:
	var parts: Array = []
	for offer in offers:
		if offer is Dictionary:
			var id := String(offer.get("id", ""))
			var tier := int(offer.get("tier", 0))
			var cost := int(offer.get("cost", 0))
			parts.append(id + ":" + str(tier) + ":" + str(cost))
	return "[" + ",".join(parts) + "]"
