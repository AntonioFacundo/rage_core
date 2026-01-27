# Game: Command interface. Allowed deps: core types + game constants.
class_name ICommand

func get_id() -> String:
	assert(false, "ICommand.get_id not implemented")
	return ""

func validate() -> Result:
	assert(false, "ICommand.validate not implemented")
	return Result.err_result("ICommand.validate not implemented")
