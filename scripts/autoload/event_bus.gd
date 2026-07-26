extends Node

@warning_ignore("unused_signal")
signal currency_changed(currency_id: String, balance: int, delta: int)
@warning_ignore("unused_signal")
signal state_changed(section: String)
@warning_ignore("unused_signal")
signal notification_requested(message: String, success: bool)
@warning_ignore("unused_signal")
signal time_speed_changed(multiplier: float)
@warning_ignore("unused_signal")
signal spawn_customer_requested
@warning_ignore("unused_signal")
signal clear_customers_requested
@warning_ignore("unused_signal")
signal save_completed(success: bool)
@warning_ignore("unused_signal")
signal scene_changed(scene_id: String)
