extends Node

var balance: Dictionary = {}
var recipes: Array = []
var crops: Array = []
var people: Dictionary = {}
var validation_errors: Array[String] = []

func _enter_tree() -> void:
	balance = _read_json("res://data/configs/balance.json", {})
	recipes = _read_json("res://data/configs/recipes.json", [])
	crops = _read_json("res://data/configs/crops.json", [])
	people = _read_json("res://data/configs/people.json", {})
	validate_all()

func _read_json(path: String, fallback: Variant) -> Variant:
	if not FileAccess.file_exists(path):
		push_error("Missing data file: " + path)
		return fallback
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	if parsed == null:
		push_error("Invalid JSON: " + path)
		return fallback
	return parsed

func validate_all() -> bool:
	validation_errors.clear()
	_validate_collection(recipes, "recipes", ["id", "name", "cook_time", "price"])
	_validate_collection(crops, "crops", ["id", "name", "growth", "yield", "value"])
	_validate_collection(people.get("customers", []), "customers", ["id", "name", "patience", "spend"])
	_validate_collection(people.get("employees", []), "employees", ["id", "name", "role", "rarity"])
	_validate_collection(balance.get("upgrades", []), "upgrades", ["id", "base", "max", "value"])
	for error in validation_errors:
		push_error("DATA: " + error)
	print("Data validation: %d errors, %d recipes, %d crops" % [validation_errors.size(), recipes.size(), crops.size()])
	return validation_errors.is_empty()

func _validate_collection(items: Array, label: String, required: Array) -> void:
	var ids: Dictionary = {}
	for item in items:
		if not item is Dictionary:
			validation_errors.append(label + " contains non-dictionary item")
			continue
		for field in required:
			if not item.has(field):
				validation_errors.append(label + " item missing " + str(field))
		var item_id := str(item.get("id", ""))
		if item_id.is_empty() or ids.has(item_id):
			validation_errors.append(label + " invalid/duplicate id: " + item_id)
		ids[item_id] = true

func get_recipe(id: String) -> Dictionary:
	return _find_by_id(recipes, id)

func get_crop(id: String) -> Dictionary:
	return _find_by_id(crops, id)

func get_upgrade(id: String) -> Dictionary:
	return _find_by_id(balance.get("upgrades", []), id)

func get_employee(id: String) -> Dictionary:
	return _find_by_id(people.get("employees", []), id)

func _find_by_id(items: Array, id: String) -> Dictionary:
	for item in items:
		if str(item.get("id", "")) == id:
			return item
	return {}

func color(id: String) -> Color:
	return Color(str(balance.get("theme", {}).get(id, "#FFFFFF")))
