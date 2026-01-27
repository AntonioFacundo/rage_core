# Platform/Godot: IPhysics2D adapter using CharacterBody2D. Allowed deps: Godot APIs only.
class_name GodotPhysics2D
extends IPhysics2D

var _bodies := {}

func register_body(body_id: String, body: CharacterBody2D) -> Result:
	if body_id == "":
		return Result.err_result("Body id is empty")
	if body == null:
		return Result.err_result("Body is null")
	_bodies[body_id] = body
	return Result.ok_result(true)

func unregister_body(body_id: String) -> void:
	_bodies.erase(body_id)

func move_body(body_id: String, velocity: Vec2, delta: float) -> Movement2DResult:
	if not _bodies.has(body_id):
		return Movement2DResult.new(Movement2DContacts.new(), velocity.copy(), Vec2.new())
	var body: CharacterBody2D = _bodies[body_id]
	body.velocity = Vector2(velocity.x, velocity.y)
	body.move_and_slide()
	var contacts := Movement2DContacts.new()
	contacts.on_floor = body.is_on_floor()
	contacts.on_wall = body.is_on_wall()
	if contacts.on_wall:
		var normal := body.get_wall_normal()
		contacts.wall_dir = -1 if normal.x > 0.0 else 1
	if contacts.on_floor:
		var floor_normal := body.get_floor_normal()
		contacts.floor_normal = Vec2.new(floor_normal.x, floor_normal.y)
		contacts.floor_angle = rad_to_deg(floor_normal.angle_to(Vector2.UP))
	var resolved_velocity := Vec2.new(body.velocity.x, body.velocity.y)
	var position := Vec2.new(body.global_position.x, body.global_position.y)
	return Movement2DResult.new(contacts, resolved_velocity, position)
