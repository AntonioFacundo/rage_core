# Game: AI config data. Allowed deps: core types + game types.
class_name AIConfig

const MODE_IDLE := "idle"
const MODE_PATROL := "patrol"
const MODE_CHASE := "chase"

var mode: String = MODE_IDLE
var patrol_left: float = 0.0
var patrol_right: float = 0.0
var target_id: String = ""

func _init(config_mode: String = MODE_IDLE) -> void:
	mode = config_mode
