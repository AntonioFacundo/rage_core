# Mods: Example movement tuning mod. Allowed deps: core + game types only.
class_name ExampleModMovementTuning
extends ModBase

var _manifest: ModManifest

func _init() -> void:
	var data := {
		"id": "example.movement_tuning",
		"version": "1.0.0",
		"requires_core": "^1.0.0",
		"requires_game": "^1.0.0",
		"deps": {},
		"load_order_hint": 10
	}
	var result := ModManifest.from_dict(data)
	if result.ok:
		_manifest = result.value

func get_manifest() -> ModManifest:
	return _manifest

func on_load(api: GameAPI) -> void:
	var config := Movement2DConfig.new()
	config.max_speed = 160.0
	config.acceleration = 1600.0
	config.deceleration = 2000.0
	config.jump_speed = 460.0
	config.coyote_time = 0.12
	config.jump_buffer = 0.12
	config.dash_speed = 360.0
	config.dash_time = 0.14
	config.dash_cooldown = 0.2
	var result := api.set_movement_config("player", config)
	if not result.ok:
		api.get_logger().error("Movement mod failed: " + str(result.error))
