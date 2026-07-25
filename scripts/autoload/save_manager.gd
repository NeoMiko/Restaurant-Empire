extends Node

const SAVE_PATH := "user://restaurant_empire_save.json"
const BACKUP_PATH := "user://restaurant_empire_save.backup.json"
const CURRENT_VERSION := 2
var _save_queued := false
var _autosave_timer: Timer
var suppress_saves := false

func _ready() -> void:
	_autosave_timer = Timer.new()
	_autosave_timer.wait_time = 30.0
	_autosave_timer.autostart = true
	_autosave_timer.timeout.connect(save_game)
	add_child(_autosave_timer)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(BACKUP_PATH)

func new_game() -> void:
	GameManager.new_game()
	save_game()

func queue_save() -> void:
	if suppress_saves:
		return
	if _save_queued:
		return
	_save_queued = true
	get_tree().create_timer(0.5).timeout.connect(save_game)

func save_game() -> bool:
	_save_queued = false
	if suppress_saves:
		return true
	GameManager.state.save_version = CURRENT_VERSION
	GameManager.state.last_save_unix = TimeManager.unix_now()
	if FileAccess.file_exists(SAVE_PATH):
		var previous := FileAccess.get_file_as_string(SAVE_PATH)
		var backup := FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
		if backup:
			backup.store_string(previous)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Unable to open save file: " + SAVE_PATH)
		EventBus.save_completed.emit(false)
		return false
	file.store_string(JSON.stringify(GameManager.state, "  "))
	EventBus.save_completed.emit(true)
	return true

func load_game() -> bool:
	var loaded := _load_path(SAVE_PATH)
	if loaded.is_empty():
		loaded = _load_path(BACKUP_PATH)
		if not loaded.is_empty():
			EventBus.notification_requested.emit("Primary save damaged; backup restored", false)
	if loaded.is_empty():
		return false
	loaded = _migrate(loaded)
	GameManager.apply_loaded(loaded)
	OfflineProgressManager.apply_elapsed(int(GameManager.state.get("last_save_unix", TimeManager.unix_now())))
	return true

func _load_path(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		return {}
	var parsed: Variant = parser.data
	if parsed is Dictionary and parsed.has("currencies"):
		return parsed
	return {}

func _migrate(data: Dictionary) -> Dictionary:
	var version := int(data.get("save_version", 0))
	if version < 1:
		data.save_version = 1
	if version < 2:
		if not data.has("offline_pending"):
			data.offline_pending = {"seconds":0,"coins":0,"xp":0}
		data.save_version = 2
	return data

func reset_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if FileAccess.file_exists(BACKUP_PATH):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(BACKUP_PATH))
	GameManager.new_game()
	EventBus.notification_requested.emit("Save reset", true)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED or what == NOTIFICATION_WM_CLOSE_REQUEST:
		save_game()

func save_snapshot_to_path(path: String, snapshot: Dictionary) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(snapshot))
	return true

func load_snapshot_from_path(path: String) -> Dictionary:
	return _load_path(path)

func remove_test_snapshot(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
