# Game: Replay stream and metadata. Allowed deps: core types + game types.
class_name ReplayStream

var metadata: Dictionary = {}
var frames: Array = []

func set_metadata(meta: Dictionary) -> void:
	metadata = meta

func add_frame(frame: ReplayFrame) -> void:
	frames.append(frame)

func get_frame(tick_index: int) -> ReplayFrame:
	for frame in frames:
		if frame.tick_index == tick_index:
			return frame
	return null

func to_dict() -> Dictionary:
	var list: Array = []
	for frame in frames:
		list.append(frame.to_dict())
	return {
		"metadata": metadata,
		"frames": list
	}

static func from_dict(data: Dictionary) -> ReplayStream:
	var stream := ReplayStream.new()
	if data.has("metadata") and data["metadata"] is Dictionary:
		stream.metadata = data["metadata"]
	var frames_data := data.get("frames", [])
	if frames_data is Array:
		for entry in frames_data:
			if entry is Dictionary:
				stream.frames.append(ReplayFrame.from_dict(entry))
	return stream
