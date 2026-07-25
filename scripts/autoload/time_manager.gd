extends Node

var speed_multiplier: float = 1.0

func set_speed(value: float) -> void:
	var allowed: Array = DataManager.balance.get("simulation", {}).get("time_speeds", [1, 2, 5, 10])
	if value not in allowed:
		value = 1.0
	speed_multiplier = value
	EventBus.time_speed_changed.emit(speed_multiplier)
	EventBus.notification_requested.emit("Simulation speed x%s" % str(speed_multiplier), true)

func cycle_speed() -> void:
	var allowed: Array = DataManager.balance.get("simulation", {}).get("time_speeds", [1, 2, 5, 10])
	var index := allowed.find(int(speed_multiplier))
	set_speed(float(allowed[(index + 1) % allowed.size()]))

func scaled(delta: float) -> float:
	return delta * speed_multiplier

func unix_now() -> int:
	return int(Time.get_unix_time_from_system())
