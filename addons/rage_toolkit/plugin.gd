@tool
extends EditorPlugin

const DOCK_SCENE := "res://addons/rage_toolkit/editor/scaffold_dock.tscn"

var _dock: Control

func _enter_tree() -> void:
	var scene := load(DOCK_SCENE)
	if scene != null:
		_dock = scene.instantiate()
		add_control_to_dock(DOCK_SLOT_RIGHT_UL, _dock)

func _exit_tree() -> void:
	if _dock != null:
		remove_control_from_docks(_dock)
		_dock.queue_free()
