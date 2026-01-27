# Mods: Validation and deterministic load order. Allowed deps: core + game types only.
class_name ModLoader

func validate(manifests: Array, core_version: String, game_version: String) -> Array:
	var errors: Array = []
	var by_id := {}
	var ordered: Array = manifests.duplicate()
	ordered.sort_custom(func(a, b):
		if not (a is ModManifest) or not (b is ModManifest):
			return false
		return a.id < b.id
	)

	for m in ordered:
		if not (m is ModManifest):
			errors.append("Invalid manifest type")
			continue
		if by_id.has(m.id):
			errors.append("Duplicate mod id: " + m.id)
		by_id[m.id] = m

	for m in ordered:
		if not SemVer.satisfies(core_version, m.requires_core):
			errors.append("Mod " + m.id + " requires core " + m.requires_core)
		if not SemVer.satisfies(game_version, m.requires_game):
			errors.append("Mod " + m.id + " requires game " + m.requires_game)
		var dep_ids = m.deps.keys()
		dep_ids.sort()
		for dep_id in dep_ids:
			if not by_id.has(dep_id):
				errors.append("Missing dependency " + dep_id + " for mod " + m.id)
				continue
			var dep_manifest: ModManifest = by_id[dep_id]
			var constraint := String(m.deps[dep_id])
			if not SemVer.satisfies(dep_manifest.version, constraint):
				errors.append("Dependency version mismatch: " + m.id + " -> " + dep_id + " " + constraint)

	return errors

func resolve_order(manifests: Array) -> Result:
	var by_id := {}
	var indegree := {}
	var graph := {}
	var ids: Array = []

	for m in manifests:
		by_id[m.id] = m
		indegree[m.id] = 0
		graph[m.id] = []
		ids.append(m.id)
	ids.sort()

	for id in ids:
		var m: ModManifest = by_id[id]
		var dep_ids := m.deps.keys()
		dep_ids.sort()
		for dep_id in dep_ids:
			graph[dep_id].append(m.id)
			indegree[m.id] = int(indegree[m.id]) + 1
	for id in ids:
		graph[id].sort()

	var available: Array = []
	for id in ids:
		if int(indegree[id]) == 0:
			available.append(id)

	var ordered: Array = []
	while available.size() > 0:
		available.sort_custom(func(a, b): return _order_before(by_id[a], by_id[b]))
		var current_id = available.pop_front()
		ordered.append(by_id[current_id])
		for next_id in graph[current_id]:
			indegree[next_id] = int(indegree[next_id]) - 1
			if int(indegree[next_id]) == 0:
				available.append(next_id)

	if ordered.size() != manifests.size():
		return Result.err_result("Dependency cycle detected in mods")

	return Result.ok_result(ordered)

func load(mods: Array, manifests: Array, api: GameAPI, core_version: String, game_version: String) -> Result:
	var errors := validate(manifests, core_version, game_version)
	if errors.size() > 0:
		return Result.err_result(errors)

	var order := resolve_order(manifests)
	if not order.ok:
		return order

	var mod_by_id := {}
	for mod in mods:
		if not (mod is ModBase):
			return Result.err_result("Mod does not extend ModBase")
		var manifest = mod.get_manifest()
		if manifest == null:
			return Result.err_result("Mod missing manifest")
		mod_by_id[manifest.id] = mod

	var loaded: Array = []
	for manifest in order.value:
		if not mod_by_id.has(manifest.id):
			return Result.err_result("Missing mod instance for " + manifest.id)
		var instance: ModBase = mod_by_id[manifest.id]
		instance.on_load(api)
		loaded.append(manifest.id)

	return Result.ok_result(loaded)

func _order_before(a: ModManifest, b: ModManifest) -> bool:
	if a.load_order_hint != b.load_order_hint:
		return a.load_order_hint < b.load_order_hint
	if a.id == b.id:
		return false
	return a.id < b.id
