# Game: Deterministic level content selector. Allowed deps: core types only.
# Uses ContentRegistry with:
# - content.room data: { tags: [String], tier: int, weight: int }
# - content.wave data: { tags: [String], tier: int, weight: int, spawns: Array }
class_name LevelSelector

const TIER_STEP := 3

func select_next_room(run_state: RunState, registry: ContentRegistry, constraints: Dictionary) -> ContentDef:
	if run_state == null or registry == null:
		return null
	var tier := _resolve_tier(run_state, constraints)
	var required_tags := _get_tags(constraints, "required_tags")
	var excluded_tags := _get_tags(constraints, "excluded_tags")
	var candidates := _filter_defs(registry.list_by_type(GameConstants.CONTENT_ROOM), tier, required_tags, excluded_tags)
	if candidates.size() == 0:
		return null
	var rng := DeterministicRng.new()
	rng.seed(_selection_seed(run_state.get_seed64(), run_state.get_stage_index(), "room"))
	return _select_weighted_def(candidates, rng)

func select_wave_for_room(run_state: RunState, registry: ContentRegistry, room_def: ContentDef, constraints: Dictionary) -> ContentDef:
	if run_state == null or registry == null or room_def == null:
		return null
	var tier := _resolve_tier(run_state, constraints)
	var required_tags := _get_tags(constraints, "required_tags")
	if required_tags.size() == 0:
		required_tags = _get_tags_from_data(room_def.data)
	var excluded_tags := _get_tags(constraints, "excluded_tags")
	var candidates := _filter_defs(registry.list_by_type(GameConstants.CONTENT_WAVE), tier, required_tags, excluded_tags)
	if candidates.size() == 0:
		return null
	var rng := DeterministicRng.new()
	var salt := "wave|" + room_def.id
	rng.seed(_selection_seed(run_state.get_seed64(), run_state.get_stage_index(), salt))
	return _select_weighted_def(candidates, rng)

func _resolve_tier(run_state: RunState, constraints: Dictionary) -> int:
	if constraints != null and constraints.has("difficulty_tier"):
		return int(constraints.get("difficulty_tier"))
	var stage_index := run_state.get_stage_index()
	return 1 + int(stage_index / float(TIER_STEP))

func _get_tags(constraints: Dictionary, key: String) -> Array:
	if constraints == null or not constraints.has(key):
		return []
	var value: Variant = constraints.get(key)
	if value is Array:
		return value.duplicate()
	return []

func _filter_defs(list: Array, tier: int, required_tags: Array, excluded_tags: Array) -> Array:
	var out: Array = []
	for def in list:
		if def == null or not (def is ContentDef):
			continue
		var data = def.data
		if not (data is Dictionary):
			continue
		var def_tier := _get_tier_from_data(data)
		if def_tier != tier:
			continue
		var tags := _get_tags_from_data(data)
		if not _tags_allow(tags, required_tags, excluded_tags):
			continue
		var weight := _get_weight_from_data(data)
		if weight <= 0:
			continue
		out.append({
			"def": def,
			"tags": tags,
			"weight": weight
		})
	return out

func _tags_allow(tags: Array, required_tags: Array, excluded_tags: Array) -> bool:
	for tag in required_tags:
		if not tags.has(tag):
			return false
	for tag in excluded_tags:
		if tags.has(tag):
			return false
	return true

func _select_weighted_def(candidates: Array, rng: DeterministicRng) -> ContentDef:
	var total := 0
	for entry in candidates:
		total += int(entry.get("weight", 1))
	var roll := rng.range_int(1, total)
	var acc := 0
	for entry in candidates:
		acc += int(entry.get("weight", 1))
		if roll <= acc:
			return entry.get("def", null)
	return candidates[0].get("def", null)

func _selection_seed(seed64: int, stage_index: int, salt: String) -> int:
	var text := salt + "|" + str(seed64) + "|" + str(stage_index)
	return Fnv1a64.hash_string(text)

func _get_tags_from_data(data: Dictionary) -> Array:
	var value = data.get("tags", [])
	if not (value is Array):
		return []
	var out: Array = []
	for tag in value:
		if tag is String:
			out.append(tag)
	return out

func _get_tier_from_data(data: Dictionary) -> int:
	return int(data.get("tier", 1))

func _get_weight_from_data(data: Dictionary) -> int:
	return max(1, int(data.get("weight", 1)))
