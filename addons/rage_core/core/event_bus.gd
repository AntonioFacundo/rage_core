# Core: Event bus with priority, interception, and cancellation. Allowed deps: core types only.
class_name EventBus

var _handlers := {}
var _token_counter: int = 0
var _order_counter: int = 0

func subscribe(event_id: String, handler: Callable, priority: int = 0, intercept: bool = false) -> int:
	_token_counter += 1
	var token := _token_counter
	var entry := {
		"token": token,
		"handler": handler,
		"priority": priority,
		"intercept": intercept,
		"order": _order_counter
	}
	_order_counter += 1
	if not _handlers.has(event_id):
		_handlers[event_id] = []
	_handlers[event_id].append(entry)
	return token

func unsubscribe(token: int) -> bool:
	for key in _handlers.keys():
		var list: Array = _handlers[key]
		for i in range(list.size()):
			if list[i]["token"] == token:
				list.remove_at(i)
				return true
	return false

func emit(event: EventBase) -> Result:
	if event == null or not (event is EventBase):
		return Result.err_result("EventBus.emit requires EventBase")

	var validation := event.validate()
	if not validation.ok:
		return validation

	var event_id := event.get_id()
	if not _handlers.has(event_id):
		return Result.ok_result(true)

	var list: Array = _handlers[event_id].duplicate()
	list.sort_custom(_handler_before)

	for entry in list:
		entry["handler"].call(event)
		if entry["intercept"]:
			validation = event.validate()
			if not validation.ok:
				return validation
		if event.is_cancelled():
			break

	return Result.ok_result(true)

func _handler_before(a, b) -> bool:
	if a["intercept"] != b["intercept"]:
		return a["intercept"] and not b["intercept"]
	if a["priority"] != b["priority"]:
		return a["priority"] > b["priority"]
	return a["order"] < b["order"]
