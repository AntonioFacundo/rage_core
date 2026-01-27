# Core: 2D movement contact data. Allowed deps: core types only.
class_name Movement2DContacts

var on_floor: bool = false
var on_wall: bool = false
var wall_dir: int = 0
var floor_normal := Vec2.new()
var floor_angle: float = 0.0
