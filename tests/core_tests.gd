extends Node

var failures := 0
var checks := 0

func _ready() -> void:
	seed(20260725)
	GameManager.new_game()
	_test_data()
	_test_economy()
	_test_upgrade_formula()
	_test_save_roundtrip()
	_test_offline_and_crops()
	_test_gacha_pity()
	await _test_order_queue()
	await _test_garden_actions()
	if failures == 0:
		print("CORE_TESTS_PASS checks=%d" % checks)
	else:
		push_error("CORE_TESTS_FAIL failures=%d checks=%d" % [failures, checks])
	get_tree().quit(1 if failures > 0 else 0)

func _check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error("ASSERT: " + message)

func _test_data() -> void:
	_check(DataManager.validation_errors.is_empty(), "resource IDs and fields must validate")
	_check(DataManager.recipes.size() == 10, "ten recipes required")
	_check(DataManager.crops.size() == 8, "eight crops required")

func _test_economy() -> void:
	var initial := EconomyManager.balance("coins")
	_check(not EconomyManager.spend("coins", initial + 1, "test overdraft"), "overdraft rejected")
	_check(EconomyManager.balance("coins") == initial, "failed spend keeps balance")
	EconomyManager.add("coins", -5, "test negative")
	_check(EconomyManager.balance("coins") == initial, "negative add rejected")
	_check(EconomyManager.spend("coins", 100, "test valid"), "valid spend accepted")
	_check(EconomyManager.balance("coins") == initial - 100, "valid spend exact")

func _test_upgrade_formula() -> void:
	var base := EconomyManager.upgrade_cost("kitchen_speed", 0)
	var level_one := EconomyManager.upgrade_cost("kitchen_speed", 1)
	_check(base == 100, "base upgrade cost")
	_check(level_one == 115, "upgrade uses 1.15 growth")
	_check(EconomyManager.upgrade_cost("kitchen_speed", 10) > level_one, "cost remains monotonic")

func _test_save_roundtrip() -> void:
	var path := "user://restaurant_empire_test.json"
	var snapshot := GameManager.state.duplicate(true)
	snapshot.currencies.coins = 12345
	_check(SaveManager.save_snapshot_to_path(path, snapshot), "test snapshot writes")
	var loaded := SaveManager.load_snapshot_from_path(path)
	_check(int(loaded.get("currencies", {}).get("coins", 0)) == 12345, "snapshot roundtrip")
	var corrupt := FileAccess.open(path, FileAccess.WRITE)
	corrupt.store_string("{broken")
	corrupt = null
	_check(SaveManager.load_snapshot_from_path(path).is_empty(), "corrupt snapshot rejected")
	SaveManager.remove_test_snapshot(path)

func _test_offline_and_crops() -> void:
	var plot: Dictionary = GameManager.state.garden[0]
	plot.status = "GROWING"
	plot.crop_id = "lettuce"
	plot.remaining = 10.0
	var future := OfflineProgressManager.apply_elapsed(TimeManager.unix_now() + 1000)
	_check(int(future.seconds) == 0, "negative clock delta clamps to zero")
	var capped := OfflineProgressManager.apply_elapsed(TimeManager.unix_now() - 36000)
	_check(int(capped.seconds) == 28800, "offline time caps at eight hours")
	_check(plot.status == "READY", "offline growth completes crop")
	_check(int(capped.coins) >= 0, "offline coins non-negative")

func _test_gacha_pity() -> void:
	var office_script: Script = load("res://scripts/staff/employment_office.gd")
	var office: Node = office_script.new()
	GameManager.state.pity_counter = 49
	_check(office._roll_rarity() == "Legendary", "pity guarantees Legendary")
	_check(int(GameManager.state.pity_counter) == 0, "pity resets")
	office.free()

func _test_order_queue() -> void:
	var packed: PackedScene = load("res://scenes/restaurant/restaurant.tscn")
	var restaurant: Node = packed.instantiate()
	add_child(restaurant)
	await get_tree().process_frame
	var recipe := DataManager.get_recipe("burger")
	var order_id: int = restaurant.place_order(999, 0, recipe)
	var order: Dictionary = restaurant.take_next_order()
	_check(order_id > 0 and int(order.id) == order_id, "restaurant FIFO order queue")
	restaurant.queue_free()
	await get_tree().process_frame

func _test_garden_actions() -> void:
	GameManager.new_game()
	var packed: PackedScene = load("res://scenes/garden/garden.tscn")
	var garden: Node = packed.instantiate()
	add_child(garden)
	await get_tree().process_frame
	var seed_before := GameManager.item_count("seeds", "lettuce")
	garden._plot_pressed(0)
	_check(GameManager.state.garden[0].status == "GROWING", "empty plot plants selected seed")
	_check(GameManager.item_count("seeds", "lettuce") == seed_before - 1, "planting consumes seed")
	GameManager.state.garden[0].remaining = 0.0
	garden._process(0.1)
	_check(GameManager.state.garden[0].status == "READY", "crop timer reaches ready")
	garden._plot_pressed(0)
	_check(GameManager.item_count("crops", "lettuce") >= 2, "harvest grants configured yield")
	garden.queue_free()
	await get_tree().process_frame
