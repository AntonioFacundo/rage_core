# Mods: Example mod that registers a simple item content. Allowed deps: game API only.
class_name ExampleItemMod
extends ModBase

const MOD_ID := "example_item_mod"

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

	var def := ContentDef.new(
		"item.mod.token",
		GameConstants.CONTENT_ITEM,
		{
			"tier": 1,
			"tags": ["mod", "token"],
			"weight": 1,
			"icon_path": "res://mods/example_item_mod/assets/item_token.png"
		},
		MOD_ID
	)
	var validation := def.validate()
	if not validation.ok:
		api.get_logger().error(MOD_ID + ": invalid content " + def.id + " " + str(validation.error))
		return
	var res := api.register_content(def)
	if not res.ok:
		api.get_logger().error(MOD_ID + ": register failed " + def.id + " " + str(res.error))
		return
	api.get_logger().info(MOD_ID + ": registered content=1")

func on_unload(_api: GameAPI) -> void:
	pass
