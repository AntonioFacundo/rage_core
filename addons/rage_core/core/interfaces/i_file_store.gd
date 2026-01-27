# Core: File store interface. Allowed deps: core types only.
class_name IFileStore

func exists(_path: String) -> bool:
	assert(false, "IFileStore.exists not implemented")
	return false

func read_text(_path: String) -> Result:
	assert(false, "IFileStore.read_text not implemented")
	return Result.err_result("not implemented")

func write_text(_path: String, _content: String) -> Result:
	assert(false, "IFileStore.write_text not implemented")
	return Result.err_result("not implemented")
