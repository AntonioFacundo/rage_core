# Mods: Example pickup mod (speed boost). Allowed deps: core + game types only.
class_name ExampleModPickupSpeed
extends ModBase

var _manifest: ModManifest

func _init() -> void:
	var data := {
		"id": "example.pickup_speed",
		"version": "1.0.0",
		"requires_core": "^1.0.0",
		"requires_game": "^1.0.0",
		"deps": {},
		"load_order_hint": 20
	}
	var result := ModManifest.from_dict(data)
	if result.ok:
		_manifest = result.value

var _speed_pickup_id := "pickup.speed"

func get_manifest() -> ModManifest:
	return _manifest

func on_load(api: GameAPI) -> void:
	if api.get_content_by_id(_speed_pickup_id) == null:
		var def := ContentDef.new(_speed_pickup_id, GameConstants.CONTENT_PICKUP, {"type": "speed_boost"}, _manifest.id)
		var res := api.register_content(def)
		if not res.ok:
			api.get_logger().error("Pickup mod register failed: " + str(res.error))
	api.subscribe(GameConstants.EVENT_PICKUP, func(event: EventBase) -> void:
		if event is PickupEvent and event.get_pickup_id() == _speed_pickup_id:
			var config := Movement2DConfig.new()
			config.max_speed = 220.0
			config.acceleration = 1800.0
			var result := api.set_movement_config(event.get_target_id(), config)
			if not result.ok:
				api.get_logger().error("Pickup mod apply failed: " + str(result.error))
	)
