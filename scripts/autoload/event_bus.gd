extends Node

signal currency_changed(currency_id: String, balance: int, delta: int)
signal state_changed(section: String)
signal notification_requested(message: String, success: bool)
signal time_speed_changed(multiplier: float)
signal spawn_customer_requested
signal clear_customers_requested
signal save_completed(success: bool)
signal scene_changed(scene_id: String)
