# Game: Card game kernel. Allowed deps: Godot + Rage Core + game layer.
extends GameKernel
class_name GameKernelGame

func _ready() -> void:
	super._ready()
	# Debug: prints pipeline order on boot (requires boot_log enabled).
	_log_pipeline_registration()
	# Content: packs from res://addons/rage_core/data_packs and res://data_packs.
	_load_content_packs()
	# Mods: load and call on_load() in deterministic order.
	_load_mods()

func _load_content_packs() -> void:
	super._load_content_packs()
	_load_content_packs_from_dir("user://data_packs")
