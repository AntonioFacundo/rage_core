# Core: 2D physics adapter interface. Allowed deps: core types only.
class_name IPhysics2D

func move_body(_body_id: String, _velocity: Vec2, _delta: float) -> Movement2DResult:
	assert(false, "IPhysics2D.move_body not implemented")
	return Movement2DResult.new(Movement2DContacts.new(), Vec2.new(), Vec2.new())

func get_body_position(_body_id: String) -> Vec2:
	assert(false, "IPhysics2D.get_body_position not implemented")
	return Vec2.new()
