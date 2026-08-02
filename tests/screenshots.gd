extends Node

## Renders every screen once and writes a PNG to tmp/screenshots/ so UI work can be reviewed
## without clicking through the game. Needs a real rendering context, so run it WITHOUT
## --headless:
##   Godot_v4.6.3-stable_win64.exe --path . res://tests/screenshots.tscn

const OUTPUT_DIR := "res://tmp/screenshots"

## name, scene, seconds to dwell before capturing. The restaurant needs long enough for a
## guest to order, a cook to start and a waiter to load a tray, or the shot only shows an
## idle room.
const SHOTS := [
	["01_menu", "res://scenes/bootstrap/main_menu.tscn", 1.2],
	["02_city", "res://scenes/city/city.tscn", 1.2],
	["03_restaurant", "res://scenes/restaurant/restaurant.tscn", 16.0],
	["04_garden", "res://scenes/garden/garden.tscn", 1.2],
	["05_shop", "res://scenes/shop/shop.tscn", 1.2],
	["06_bazaar", "res://scenes/bazaar/bazaar.tscn", 1.2],
	["07_fairy", "res://scenes/fairy/fairy.tscn", 1.2],
	["08_office", "res://scenes/office/employment_office.tscn", 1.2],
	["09_progression", "res://scenes/progression/progression.tscn", 1.2],
	["10_house", "res://scenes/house/house.tscn", 1.2],
	["11_settings", "res://scenes/ui/settings.tscn", 1.2]
]

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	## The tutorial popup would cover the city grid in every shot.
	GameManager.state.tutorial = {"step": 0, "completed": true}
	_seed_garden()
	for shot in SHOTS:
		await _capture(str(shot[0]), str(shot[1]), float(shot[2]))
	print("SCREENSHOTS_DONE count=%d dir=%s" % [SHOTS.size(), OUTPUT_DIR])
	get_tree().quit()

## A fresh save has every plot empty, which never exercises the crop artwork.
func _seed_garden() -> void:
	var samples := [
		{"status": "GROWING", "crop_id": "tomato", "remaining": 26.0},
		{"status": "READY", "crop_id": "strawberry", "remaining": 0.0},
		{"status": "GROWING", "crop_id": "corn", "remaining": 120.0},
		{"status": "READY", "crop_id": "lettuce", "remaining": 0.0}
	]
	for index in min(samples.size(), GameManager.state.garden.size()):
		var plot: Dictionary = GameManager.state.garden[index]
		for key in samples[index]:
			plot[key] = samples[index][key]
		plot["fertiliser"] = ""

func _capture(shot_name: String, scene_path: String, dwell: float) -> void:
	var packed: PackedScene = load(scene_path)
	if packed == null:
		push_error("SHOT_LOAD_FAIL " + scene_path)
		return
	var instance: Node = packed.instantiate()
	add_child(instance)
	for _frame in 4:
		await get_tree().process_frame
	await get_tree().create_timer(dwell).timeout
	var image := get_viewport().get_texture().get_image()
	image.save_png("%s/%s.png" % [OUTPUT_DIR, shot_name])
	instance.queue_free()
	await get_tree().process_frame
