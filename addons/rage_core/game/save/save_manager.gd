# Game: Save manager using schema + ISaveStore. Allowed deps: core types + game types.
class_name SaveManager

var _store: ISaveStore
var _logger: ILogger

func _init(store: ISaveStore, logger: ILogger) -> void:
	_store = store
	_logger = logger

func save_state(state: GameState, key: String) -> Result:
	var data := SaveSchema.encode(state)
	return _store.save_json(key, data)

func load_state(state: GameState, key: String) -> Result:
	var res := _store.load_json(key)
	if not res.ok:
		return res
	if not (res.value is Dictionary):
		return Result.err_result("Save data is not a dictionary")
	var decode := SaveSchema.decode(state, res.value)
	if not decode.ok:
		_logger.error("Save decode failed: " + str(decode.error))
	return decode
