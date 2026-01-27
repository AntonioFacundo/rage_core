# Game: Deterministic shop resolver. Allowed deps: core types only.
class_name ShopResolveSystem
extends SimulationStep

var _run_state: RunState

func _init(run_state: RunState) -> void:
	_run_state = run_state

func run(context: SimulationContext, _delta: float) -> void:
	if _run_state == null or context == null:
		return
	if not _run_state.is_run_active():
		return
	if not _run_state.is_shop_active():
		return
	if _run_state.get_tower_stage() != "rooms":
		return
	if not _run_state.is_shop_ready():
		_run_state.set_shop_ready(true)
		return

	var offers := _run_state.list_shop_offers()
	var currency := _run_state.get_currency()
	var chosen := _pick_offer(offers, currency)
	if chosen.is_empty():
		context.logger.info("[SHOP] skip")
	else:
		var cost := int(chosen.get("cost", 0))
		if _run_state.spend_currency(cost):
			_apply_effect(chosen)
			context.logger.info("[SHOP] buy offer=" + String(chosen.get("id", "")) + " cost=" + str(cost))
		else:
			context.logger.info("[SHOP] skip")

	var health_pickups := _run_state.get_shop_health_pickups()
	if health_pickups > 0:
		_run_state.add_run_health(health_pickups)
		context.logger.info("[HP] heal source=shop amount=" + str(health_pickups) + " health=" + str(_run_state.get_run_health()))

	_run_state.set_shop_active(false)
	_run_state.set_shop_resolved(true)
	_run_state.set_shop_ready(false)
	_run_state.clear_shop_offers()
	_run_state.set_shop_health_pickups(0)

	context.logger.info("[SHOP] close currency_remaining=" + str(_run_state.get_currency()) + " health_added=" + str(health_pickups) + " health_total=" + str(_run_state.get_run_health()))

func _pick_offer(offers: Array, currency: int) -> Dictionary:
	var best := {}
	var best_tier := -1
	var best_cost := 0
	var best_id := ""
	for offer in offers:
		if not (offer is Dictionary):
			continue
		var tier := int(offer.get("tier", 0))
		if tier <= 0:
			continue
		var cost := int(offer.get("cost", 0))
		if cost > currency:
			continue
		var offer_id := String(offer.get("id", ""))
		var better := false
		if tier > best_tier:
			better = true
		elif tier == best_tier:
			if cost < best_cost:
				better = true
			elif cost == best_cost and offer_id < best_id:
				better = true
		if better:
			best = offer
			best_tier = tier
			best_cost = cost
			best_id = offer_id
	if best_tier < 0:
		return {}
	return best

func _apply_effect(offer: Dictionary) -> void:
	var effect = offer.get("effect", {})
	if not (effect is Dictionary):
		return
	var effect_type := String(effect.get("type", ""))
	var value := int(effect.get("value", 0))
	if value <= 0:
		return
	if effect_type == "damage_mult_bp":
		_run_state.add_damage_mult_bp(value)
	elif effect_type == "drop_mult_bp":
		_run_state.add_drop_mult_bp(value)
