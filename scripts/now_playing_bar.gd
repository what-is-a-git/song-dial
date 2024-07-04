extends ProgressBar


@onready var label: Label = $label
var focused: bool = false


func _on_value_changed(value: float) -> void:
	label.text = '%s / %s' % [Globals.format_seconds(value), 
			Globals.format_seconds(max_value)]


func _input(event: InputEvent) -> void:
	if not focused:
		return
	if not (event is InputEventMouseMotion or event is InputEventMouseButton):
		return
	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	var mouse_pos: Vector2 = get_global_mouse_position()
	var normalized_pos: float = (mouse_pos.x - global_position.x) / size.x
	var time: float = normalized_pos * max_value
	
	if not AudioManager.main.playing:
		AudioManager.main.play()
	AudioManager.main.seek(time)


func _on_mouse_entered() -> void:
	focused = true


func _on_mouse_exited() -> void:
	focused = false
