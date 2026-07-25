extends Node

func apply_settings() -> void:
	var settings: Dictionary = GameManager.state.get("settings", {})
	_set_bus("Music", float(settings.get("music", 0.7)))
	_set_bus("SFX", float(settings.get("sfx", 0.8)))

func _set_bus(bus_name: String, linear: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index >= 0:
		AudioServer.set_bus_volume_db(index, linear_to_db(clamp(linear, 0.001, 1.0)))
