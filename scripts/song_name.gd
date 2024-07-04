extends Label


var focused: bool = false
var suffix: String = ''


func _input(event: InputEvent) -> void:
	if not focused:
		return
	if NowPlaying.queue.is_empty():
		return
	if not event is InputEventMouseButton:
		return
	if not event.is_pressed():
		return
	if not event.button_index == MOUSE_BUTTON_LEFT:
		return
	
	if suffix.is_empty():
		suffix = '.%s' % NowPlaying.queue[NowPlaying.index].path.get_extension()
	else:
		suffix = ''


func _on_mouse_entered() -> void:
	focused = true


func _on_mouse_exited() -> void:
	focused = false
