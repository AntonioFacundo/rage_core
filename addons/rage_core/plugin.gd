@tool
extends EditorPlugin

const AUTOLOAD_NAME := "Kernel"
const AUTOLOAD_PATH := "res://addons/rage_core/kernel/game_kernel.gd"

var _added_autoload := false
var _added_menu := false

const MENU_LIVE := "Replay Mode: Live (Rage Core)"
const MENU_RECORD := "Replay Mode: Record (Rage Core)"
const MENU_REPLAY := "Replay Mode: Replay (Rage Core)"
const MENU_TESTS := "Run Core Tests (Rage Core)"

func _enter_tree() -> void:
	if not ProjectSettings.has_setting("autoload/" + AUTOLOAD_NAME):
		add_autoload_singleton(AUTOLOAD_NAME, AUTOLOAD_PATH)
		_added_autoload = true
	_add_replay_menu()

func _exit_tree() -> void:
	if _added_autoload:
		remove_autoload_singleton(AUTOLOAD_NAME)
	_remove_replay_menu()

func _add_replay_menu() -> void:
	if _added_menu:
		return
	add_tool_menu_item(MENU_LIVE, func(): _set_replay_mode("live"))
	add_tool_menu_item(MENU_RECORD, func(): _set_replay_mode("record"))
	add_tool_menu_item(MENU_REPLAY, func(): _set_replay_mode("replay"))
	add_tool_menu_item(MENU_TESTS, func(): _run_core_tests())
	_added_menu = true

func _remove_replay_menu() -> void:
	if not _added_menu:
		return
	remove_tool_menu_item(MENU_LIVE)
	remove_tool_menu_item(MENU_RECORD)
	remove_tool_menu_item(MENU_REPLAY)
	remove_tool_menu_item(MENU_TESTS)
	_added_menu = false

func _set_replay_mode(mode: String) -> void:
	ProjectSettings.set_setting("rage_core/replay/mode", mode)
	ProjectSettings.save()
	print("Rage Core replay mode set to: " + mode)

func _run_core_tests() -> void:
	var result := RageCoreTests.run_all()
	if result.get("ok", false):
		print("Rage Core Tests: PASS (" + str(result.get("passed", 0)) + "/" + str(result.get("total", 0)) + ", " + str(result.get("percent", 0.0)) + "%)")
	else:
		push_error("Rage Core Tests: FAIL (" + str(result.get("passed", 0)) + "/" + str(result.get("total", 0)) + ", " + str(result.get("percent", 0.0)) + "%) " + str(result.get("errors", [])))
