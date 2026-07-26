extends Node

const SCENES := {
	"menu":"res://scenes/bootstrap/main_menu.tscn",
	"city":"res://scenes/city/city.tscn",
	"restaurant":"res://scenes/restaurant/restaurant.tscn",
	"garden":"res://scenes/garden/garden.tscn",
	"bazaar":"res://scenes/bazaar/bazaar.tscn",
	"shop":"res://scenes/shop/shop.tscn",
	"house":"res://scenes/house/house.tscn",
	"fairy":"res://scenes/fairy/fairy.tscn",
	"office":"res://scenes/office/employment_office.tscn",
	"progression":"res://scenes/progression/progression.tscn",
	"settings":"res://scenes/ui/settings.tscn",
	"loading":"res://scenes/ui/loading_screen.tscn"
}
var current_scene_id := "boot"
var _transitioning := false

func go_to(scene_id: String) -> void:
	if _transitioning or not SCENES.has(scene_id):
		return
	_transitioning = true
	_change.call_deferred(scene_id)

func _change(scene_id: String) -> void:
	var layer := CanvasLayer.new()
	layer.layer = 100
	var overlay := ColorRect.new()
	overlay.color = Color(0.04, 0.06, 0.08, 0.92)
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var label := Label.new()
	label.text = "Loading " + scene_id.capitalize() + "..."
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 36)
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(label)
	layer.add_child(overlay)
	get_tree().root.add_child(layer)
	await get_tree().process_frame
	var error := get_tree().change_scene_to_file(SCENES[scene_id])
	if error != OK:
		push_error("Scene transition failed: " + scene_id)
	else:
		current_scene_id = scene_id
		EventBus.scene_changed.emit(scene_id)
	await get_tree().process_frame
	layer.queue_free()
	_transitioning = false

func go_back() -> void:
	if current_scene_id == "settings":
		go_to("menu")
	elif current_scene_id == "menu":
		get_tree().quit()
	else:
		go_to("city")
