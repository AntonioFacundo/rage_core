# Presentation: Event listener for debug output. Allowed deps: Godot + kernel facade.
extends Node

@export var kernel_path: NodePath
var _token: int = -1

func _ready() -> void:
	var kernel := get_node_or_null(kernel_path)
	if kernel == null:
		push_error("DebugListener: kernel not found")
		return
	var api = kernel.get_api()
	var res = api.subscribe(GameConstants.EVENT_DAMAGE, func(event):
		if event.get_id() == GameConstants.EVENT_DAMAGE:
			var payload = event.get_payload()
			print("DamageEvent:", payload.get("attacker_id"), payload.get("target_id"), payload.get("amount"))
	, 0, false)
	if res.ok:
		_token = int(res.value)

func _exit_tree() -> void:
	if _token >= 0:
		var kernel := get_node_or_null(kernel_path)
		if kernel != null:
			kernel.get_api().unsubscribe(_token)
