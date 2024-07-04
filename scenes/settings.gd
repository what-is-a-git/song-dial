extends Button


var target_alpha: float = 0.75


func _process(delta: float) -> void:
	modulate.a = lerpf(modulate.a, target_alpha, delta * 3.0)


func _on_mouse_entered() -> void:
	target_alpha = 0.75


func _on_mouse_exited() -> void:
	if not Config.get_value('app', 'always_show_settings'):
		target_alpha = 0.0
	else:
		target_alpha = 0.75
