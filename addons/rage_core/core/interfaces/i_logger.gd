# Core: Logger interface. Allowed deps: none.
class_name ILogger

func info(_message: String) -> void:
	assert(false, "ILogger.info not implemented")

func warn(_message: String) -> void:
	assert(false, "ILogger.warn not implemented")

func error(_message: String) -> void:
	assert(false, "ILogger.error not implemented")
