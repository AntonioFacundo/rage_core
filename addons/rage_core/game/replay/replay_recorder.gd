# Game: Replay recorder. Allowed deps: core types + game types.
class_name ReplayRecorder

var _stream: ReplayStream
var _active: bool = false
var _store: IFileStore

func start(meta: Dictionary, store: IFileStore) -> void:
	_stream = ReplayStream.new()
	_stream.set_metadata(meta)
	_active = true
	_store = store

func record_frame(snapshot: InputSnapshot, tick_index: int) -> void:
	if not _active:
		return
	var actions := _serialize_actions(snapshot)
	var axes := _serialize_axes(snapshot)
	_stream.add_frame(ReplayFrame.new(tick_index, actions, axes))

func stop() -> ReplayStream:
	_active = false
	return _stream

func set_hashes(hashes: Array) -> void:
	if _stream != null:
		var meta := _stream.metadata
		meta["hashes"] = hashes
		_stream.set_metadata(meta)

func save_json(path: String) -> Result:
	if _store == null:
		return Result.err_result("ReplayRecorder missing file store")
	var data := _stream.to_dict()
	var text := JSON.stringify(data)
	return _store.write_text(path, text)

func _serialize_actions(snapshot: InputSnapshot) -> Array:
	var out: Array = []
	var ids := snapshot.get_action_ids()
	ids.sort()
	for action_id in ids:
		var pressed := snapshot.is_pressed(action_id)
		out.append([action_id, pressed])
	return out

func _serialize_axes(snapshot: InputSnapshot) -> Array:
	var out: Array = []
	var ids := snapshot.get_axis_ids()
	ids.sort()
	for axis_id in ids:
		var value := snapshot.get_axis(axis_id)
		out.append([axis_id, value])
	return out
