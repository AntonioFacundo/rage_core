# Core: 2D vector value object. Allowed deps: none.
class_name Vec2

var x: float
var y: float

func _init(x_value: float = 0.0, y_value: float = 0.0) -> void:
	x = x_value
	y = y_value

func copy() -> Vec2:
	return Vec2.new(x, y)

func add(other: Vec2) -> Vec2:
	return Vec2.new(x + other.x, y + other.y)

func scaled(scalar: float) -> Vec2:
	return Vec2.new(x * scalar, y * scalar)

func clamp_x(min_value: float, max_value: float) -> Vec2:
	var clamped := x
	if clamped < min_value:
		clamped = min_value
	if clamped > max_value:
		clamped = max_value
	return Vec2.new(clamped, y)

func clamp_y(min_value: float, max_value: float) -> Vec2:
	var clamped := y
	if clamped < min_value:
		clamped = min_value
	if clamped > max_value:
		clamped = max_value
	return Vec2.new(x, clamped)
