extends Node


var window_focused: bool = true


func format_seconds(seconds: float) -> String:
	return '%d:%02d' % [floorf(seconds / 60.0), fmod(seconds, 60.0)]


func _ready() -> void:
	var window := get_window()
	window.focus_entered.connect(_on_window_focused)
	window.focus_exited.connect(_on_window_unfocused)


func _on_window_focused() -> void:
	window_focused = true
	# VSync limited
	Engine.max_fps = 0


func _on_window_unfocused() -> void:
	window_focused = false
	await get_tree().create_timer(1.0).timeout
	
	if not window_focused:
		Engine.max_fps = 15
