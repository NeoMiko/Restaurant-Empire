extends Node

func _ready() -> void:
	get_node("/root/SaveManager").suppress_saves = true
	seed(12345)
	TimeManager.set_speed(10.0)
	var packed: PackedScene = load("res://scenes/restaurant/restaurant.tscn")
	var restaurant: Node = packed.instantiate()
	add_child(restaurant)
	await get_tree().create_timer(8.0).timeout
	var served := int(GameManager.state.stats.get("customers_served", 0))
	var coins := EconomyManager.balance("coins")
	if served < 1 or coins <= 500:
		push_error("RESTAURANT_SMOKE_FAIL served=%d coins=%d" % [served, coins])
		get_tree().quit(1)
		return
	print("RESTAURANT_SMOKE_PASS served=%d coins=%d" % [served, coins])
	get_tree().quit(0)
