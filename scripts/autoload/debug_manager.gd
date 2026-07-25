extends Node

var enabled := OS.is_debug_build() or Engine.is_editor_hint()

func add_test_resources() -> void:
	EconomyManager.add("coins", 10000, "debug")
	EconomyManager.add("diamonds", 100, "debug")
	EconomyManager.add("gacha_tickets", 50, "debug")
	EconomyManager.add("reputation", 100, "debug")

func unlock_all() -> void:
	for recipe in DataManager.recipes:
		if str(recipe.id) not in GameManager.state.unlocked_recipes:
			GameManager.state.unlocked_recipes.append(str(recipe.id))
	for building in DataManager.balance.get("buildings", []):
		if str(building.id) not in GameManager.state.unlocked_buildings:
			GameManager.state.unlocked_buildings.append(str(building.id))
	EventBus.state_changed.emit("all")

func finish_crops() -> void:
	for plot in GameManager.state.garden:
		if plot.status == "GROWING":
			plot.remaining = 0.0
			plot.status = "READY"
	EventBus.state_changed.emit("garden")
