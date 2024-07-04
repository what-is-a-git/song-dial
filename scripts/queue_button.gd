extends Button


func _process(delta: float) -> void:
	if NowPlaying.queue.is_empty():
		modulate.a = lerpf(modulate.a, 0.5, delta * 6.0)
	else:
		modulate.a = lerpf(modulate.a, 0.9, delta * 6.0)


func _on_pressed() -> void:
	Queue.instance.toggle()
