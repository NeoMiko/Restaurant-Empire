extends Node

## Single lookup point for the medieval art pack in assets/.
## Sprite files are named after the identifiers in data/configs/*.json, so most art resolves
## straight from a data id. The maps below cover the ids that have no same-named sprite.

## SVG is the shipping format — 230 KB against 6.6 MB for the identical PNG set, and it
## rescales cleanly. assets/png/ is excluded from export in export_presets.cfg, so the PNG
## fallback below only resolves in the editor: every id must exist as an SVG.
const SVG_ROOT := "res://assets/svg/"
const PNG_ROOT := "res://assets/png/"

const UPGRADE_ICONS := {
	"kitchen_speed": "chef_speed",
	"kitchen_capacity": "kitchen_station",
	"waiter_speed": "waiter_speed",
	"waiter_capacity": "waiter_tray",
	"table_count": "table_free",
	"table_capacity": "table_occupied",
	"customer_patience": "customers",
	"meal_value": "income",
	"tips": "tips",
	"restaurant_reputation": "hud_reputation",
	"garden_plot_count": "plot_empty",
	"crop_yield": "crop_yield",
	"offline_earnings": "house"
}

const STAT_ICONS := {
	"income": "income",
	"customers": "customers",
	"chef_speed": "chef_speed",
	"waiter_speed": "waiter_speed",
	"crop_yield": "crop_yield",
	"tips": "tips",
	"meal_value": "income",
	"customer_patience": "customers",
	"offline_earnings": "house",
	"restaurant_reputation": "hud_reputation",
	"customers_served": "customers",
	"crops_harvested": "crop_yield",
	"coins_earned": "hud_coins",
	"staff_collected": "office",
	"player_level": "ui_wax_seal_star"
}

const ROLE_ICONS := {
	"Chef": "chef_speed",
	"Waiter": "waiter_tray",
	"Cashier": "hud_coins",
	"Cleaner": "table_cleaning",
	"Manager": "ui_wax_seal_star"
}

const PLOT_ICONS := {
	"EMPTY": "plot_empty",
	"GROWING": "plot_growing",
	"READY": "plot_ready",
	"LOCKED": "plot_locked"
}

const TABLE_ICONS := [
	"table_free", "table_reserved", "table_occupied",
	"table_waiting_for_cleaning", "table_cleaning"
]

var _texture_cache: Dictionary = {}
var _warned: Dictionary = {}
var _body_styles: Dictionary = {}


func texture(id: String) -> Texture2D:
	if id.is_empty():
		return null
	if _texture_cache.has(id):
		return _texture_cache[id]
	for path in [SVG_ROOT + id + ".svg", PNG_ROOT + id + ".png"]:
		if ResourceLoader.exists(path):
			var loaded := load(path) as Texture2D
			_texture_cache[id] = loaded
			return loaded
	if not _warned.has(id):
		_warned[id] = true
		push_warning("Missing art asset: " + id)
	_texture_cache[id] = null
	return null


func has(id: String) -> bool:
	return texture(id) != null


func upgrade_icon(id: String) -> String:
	return str(UPGRADE_ICONS.get(id, id))


func stat_icon(stat: String) -> String:
	return str(STAT_ICONS.get(stat, stat))


func role_icon(role: String) -> String:
	return str(ROLE_ICONS.get(role, "office"))


func currency_icon(id: String) -> String:
	return "hud_" + id


func plot_icon(status: String) -> String:
	return str(PLOT_ICONS.get(status, "plot_empty"))


func table_icon(state: int) -> String:
	return TABLE_ICONS[clampi(state, 0, TABLE_ICONS.size() - 1)]


## Control helpers -------------------------------------------------------------------------

func icon_rect(id: String, minimum_size: Vector2, stretch := TextureRect.STRETCH_KEEP_ASPECT_CENTERED) -> TextureRect:
	var rect := TextureRect.new()
	rect.texture = texture(id)
	rect.custom_minimum_size = minimum_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = stretch
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


func apply_button_icon(button: Button, id: String, maximum_width: int = 64) -> Button:
	var art := texture(id)
	if art == null:
		return button
	button.icon = art
	button.expand_icon = true
	## icon_max_width is a Button theme constant, not a property.
	button.add_theme_constant_override("icon_max_width", maximum_width)
	button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
	return button


## Node2D helper ---------------------------------------------------------------------------

## Draws art centred on `centre`, scaled to fit inside `box` without distortion.
## Returns false when the id has no art so callers can fall back to primitives.
func draw_icon(canvas: CanvasItem, id: String, centre: Vector2, box: Vector2, modulate := Color.WHITE) -> bool:
	var art := texture(id)
	if art == null:
		return false
	var source := Vector2(art.get_size())
	if source.x <= 0.0 or source.y <= 0.0:
		return false
	var scale: float = min(box.x / source.x, box.y / source.y)
	var drawn := source * scale
	canvas.draw_texture_rect(art, Rect2(centre - drawn * 0.5, drawn), false, modulate)
	return true


## Cached because the restaurant agents redraw every frame.
func body_style(color: Color, radius: int = 18) -> StyleBoxFlat:
	var key := "%s|%d" % [color.to_html(false), radius]
	if _body_styles.has(key):
		return _body_styles[key]
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(radius)
	style.set_border_width_all(3)
	style.border_color = DataManager.color("outline")
	_body_styles[key] = style
	return style


## The pack ships no character sprites, so staff and guests are drawn as outlined bodies
## carrying the closest available icon. Keeps them in the same art direction as the room.
func draw_character(canvas: CanvasItem, rect: Rect2, body: Color, icon_id: String) -> void:
	canvas.draw_style_box(body_style(body), rect)
	draw_icon(canvas, icon_id, rect.position + rect.size * 0.5, rect.size * 0.62)


func draw_meter(canvas: CanvasItem, rect: Rect2, fraction: float, fill: Color) -> void:
	canvas.draw_rect(rect, DataManager.color("outline"), true)
	var inner := rect.grow(-2.0)
	inner.size.x *= clampf(fraction, 0.0, 1.0)
	canvas.draw_rect(inner, fill, true)
