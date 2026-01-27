# Mods: Manifest data and validation. Allowed deps: core types only.
class_name ModManifest

var id: String
var version: String
var requires_core: String
var requires_game: String
var deps := {}
var load_order_hint: int = 0

static func from_dict(data: Dictionary) -> Result:
	if not data.has("id") or typeof(data["id"]) != TYPE_STRING:
		return Result.err_result("Manifest missing id")
	if not data.has("version") or typeof(data["version"]) != TYPE_STRING:
		return Result.err_result("Manifest missing version")

	var manifest := ModManifest.new()
	manifest.id = data["id"]
	manifest.version = data["version"]
	manifest.requires_core = String(data.get("requires_core", ">=0.0.0"))
	manifest.requires_game = String(data.get("requires_game", ">=0.0.0"))
	manifest.deps = data.get("deps", {})
	manifest.load_order_hint = int(data.get("load_order_hint", 0))

	var v := SemVer.parse(manifest.version)
	if not v.ok:
		return Result.err_result("Invalid manifest version: " + manifest.version)
	if not Ids.is_valid_id(manifest.id):
		return Result.err_result("Invalid manifest id: " + manifest.id)
	if typeof(manifest.deps) != TYPE_DICTIONARY:
		return Result.err_result("deps must be a Dictionary")
	return Result.ok_result(manifest)
