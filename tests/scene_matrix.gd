extends Node

const SCENES := [
	"res://scenes/bootstrap/main_menu.tscn",
	"res://scenes/city/city.tscn",
	"res://scenes/restaurant/restaurant.tscn",
	"res://scenes/garden/garden.tscn",
	"res://scenes/bazaar/bazaar.tscn",
	"res://scenes/shop/shop.tscn",
	"res://scenes/house/house.tscn",
	"res://scenes/fairy/fairy.tscn",
	"res://scenes/office/employment_office.tscn",
	"res://scenes/progression/progression.tscn",
	"res://scenes/ui/settings.tscn",
	"res://scenes/ui/legal.tscn",
	"res://scenes/ui/loading_screen.tscn"
]

func _ready() -> void:
	var failures := 0
	for path in SCENES:
		var packed: PackedScene = load(path)
		if packed == null:
			push_error("SCENE_LOAD_FAIL " + path)
			failures += 1
			continue
		var instance: Node = packed.instantiate()
		add_child(instance)
		await get_tree().process_frame
		await get_tree().process_frame
		if instance.get_script() == null:
			push_error("SCENE_SCRIPT_FAIL " + path)
			failures += 1
		instance.queue_free()
		await get_tree().process_frame
	if failures == 0:
		print("SCENE_MATRIX_PASS scenes=%d" % SCENES.size())
	else:
		push_error("SCENE_MATRIX_FAIL failures=%d" % failures)
	get_tree().quit(1 if failures > 0 else 0)
