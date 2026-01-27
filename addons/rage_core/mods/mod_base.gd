# Mods: Base class for mods. Allowed deps: game API only.
class_name ModBase

func get_manifest() -> ModManifest:
	assert(false, "ModBase.get_manifest not implemented")
	return null

func on_load(_api: GameAPI) -> void:
	# Mod entry point: add your game logic here (register content, events, tuning).
	assert(false, "ModBase.on_load not implemented")

func on_unload(_api: GameAPI) -> void:
	# Optional cleanup hook for removing listeners or transient state.
	assert(false, "ModBase.on_unload not implemented")
