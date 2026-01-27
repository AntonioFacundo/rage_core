# Mods: Example mod that doubles damage via intercept. Allowed deps: game API only.
class_name ExampleModDoubleDamage
extends ModBase

var _manifest: ModManifest
var _token: int = -1

func _init() -> void:
	var data := {
		"id": "example_double_damage",
		"version": "1.0.0",
		"requires_core": "^1.0.0",
		"requires_game": "^1.0.0",
		"deps": {},
		"load_order_hint": 0
	}
	var result := ModManifest.from_dict(data)
	if result.ok:
		_manifest = result.value

func get_manifest() -> ModManifest:
	return _manifest

func on_load(api: GameAPI) -> void:
	var res := api.subscribe(GameAPI.EVENT_DAMAGE, func(event):
		if event.get_id() == GameAPI.EVENT_DAMAGE:
			var payload = event.get_payload()
			var amount := int(payload.get("amount", 0))
			payload["amount"] = amount * 2
			event.set_payload(payload)
			api.get_logger().info("example_double_damage: doubled damage")
	, 100, true)
	if not res.ok:
		api.get_logger().error("example_double_damage: subscribe failed")
	else:
		_token = int(res.value)

func on_unload(api: GameAPI) -> void:
	if _token >= 0:
		api.unsubscribe(_token)
