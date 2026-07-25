extends Node

var last_message := ""
var last_success := true

func _ready() -> void:
	EventBus.notification_requested.connect(_on_notification)

func _on_notification(message: String, success: bool) -> void:
	last_message = message
	last_success = success
	print("NOTICE: " + message)
