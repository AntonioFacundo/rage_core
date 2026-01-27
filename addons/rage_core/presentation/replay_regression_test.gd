# Presentation: Replay regression harness. Allowed deps: Godot + all layers.
extends Node

const TICKS_TARGET := 240
const REPLAY_PATH := "user://rage_replay_regression.rage_replay.json"

var _kernel: GameKernel
var _phase: String = "record"

func _ready() -> void:
	_start_record()

func _process(_delta: float) -> void:
	if _kernel == null:
		return
	if _kernel.get_tick_index() >= TICKS_TARGET:
		if _phase == "record":
			call_deferred("_finish_record")
		elif _phase == "replay":
			_finish_replay()

func _start_record() -> void:
	ProjectSettings.set_setting("rage_core/replay/mode", "record")
	ProjectSettings.set_setting("rage_core/replay/path", REPLAY_PATH)
	ProjectSettings.set_setting("rage_core/replay/seed8", "AAAA0000")
	ProjectSettings.set_setting("rage_core/replay/tick_rate", 60)
	_kernel = GameKernel.new()
	_kernel.set_input_source(SyntheticInputSource.new())
	add_child(_kernel)
	_phase = "record"

func _finish_record() -> void:
	if _kernel != null:
		_kernel.queue_free()
		await _kernel.tree_exited
	_kernel = null
	_start_replay()

func _start_replay() -> void:
	ProjectSettings.set_setting("rage_core/replay/mode", "replay")
	ProjectSettings.set_setting("rage_core/replay/path", REPLAY_PATH)
	_kernel = GameKernel.new()
	add_child(_kernel)
	_phase = "replay"

func _finish_replay() -> void:
	print("REPLAY REGRESSION PASS: ticks=", TICKS_TARGET)
	if _kernel != null:
		_kernel.queue_free()
	_kernel = null
