# Core: 2D movement runtime state. Allowed deps: core types only.
class_name Movement2DState

var velocity := Vec2.new()
var facing: int = 1
var is_grounded: bool = false
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var dash_timer: float = 0.0
var dash_cooldown: float = 0.0
var last_floor_angle: float = 0.0
var last_floor_normal := Vec2.new()
var on_ladder: bool = false

func reset_timers() -> void:
	coyote_timer = 0.0
	jump_buffer_timer = 0.0
	dash_timer = 0.0
	dash_cooldown = 0.0
