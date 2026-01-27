# Mods: Example mod that registers additional level content. Allowed deps: game API only.
class_name ExampleLevelMod
extends ModBase

const MOD_ID := "example_level_mod"

var _manifest: ModManifest

func _init() -> void:
	var data := {
		"id": MOD_ID,
		"version": "0.1.0",
		"requires_core": "^1.0.0",
		"requires_game": "^1.0.0",
		"deps": {},
		"load_order_hint": 0
	}
	var res := ModManifest.from_dict(data)
	if res.ok:
		_manifest = res.value

func get_manifest() -> ModManifest:
	return _manifest

func on_load(api: GameAPI) -> void:
	if _manifest == null:
		api.get_logger().error(MOD_ID + ": missing manifest")
		return

	var defs := [
		ContentDef.new(
			"enemy.mod.basic",
			GameConstants.CONTENT_ENEMY,
			{ "tier": 1, "tags": ["mod", "basic"], "weight": 1 },
			MOD_ID
		),
		ContentDef.new(
			"room.mod.start",
			GameConstants.CONTENT_ROOM,
			{ "tier": 1, "tags": ["mod", "start"], "weight": 1 },
			MOD_ID
		),
		ContentDef.new(
			"wave.mod.start",
			GameConstants.CONTENT_WAVE,
			{
				"tier": 1,
				"tags": ["mod", "start"],
				"weight": 1,
				"spawns": [
					{ "enemy_id": "enemy.mod.basic", "count": 3 }
				]
			},
			MOD_ID
		),
		ContentDef.new(
			"sound.mod.room_enter",
			GameConstants.CONTENT_SOUND,
			{ "path": "res://mods/example_level_mod/assets/sfx/room_enter.ogg" },
			MOD_ID
		)
	]

	for def in defs:
		var validation = def.validate()
		if not validation.ok:
			api.get_logger().error(MOD_ID + ": invalid content " + def.id + " " + str(validation.error))
			continue
		var res := api.register_content(def)
		if not res.ok:
			api.get_logger().error(MOD_ID + ": register failed " + def.id + " " + str(res.error))
	api.get_logger().info(MOD_ID + ": registered content=" + str(defs.size()))

func on_unload(_api: GameAPI) -> void:
	pass
