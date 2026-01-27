# Core: Save store interface. Allowed deps: core types only.
class_name ISaveStore

func save_json(_key: String, _data: Dictionary) -> Result:
	assert(false, "ISaveStore.save_json not implemented")
	return Result.err_result("not implemented")

func load_json(_key: String) -> Result:
	assert(false, "ISaveStore.load_json not implemented")
	return Result.err_result("not implemented")

func delete(_key: String) -> Result:
	assert(false, "ISaveStore.delete not implemented")
	return Result.err_result("not implemented")
