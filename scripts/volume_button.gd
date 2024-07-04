extends TextureRect


const VOLUME_UP := preload('res://assets/images/icons/volume_up.svg')
const VOLUME_DOWN := preload('res://assets/images/icons/volume_down.svg')
const VOLUME_OFF := preload('res://assets/images/icons/volume_off.svg')

@onready var bar: ProgressBar = %volume_bar

var focused: bool = false
var tween: Tween
var volume: float = 25.0


func _ready() -> void:
	_on_mouse_exited()
	_update_icon()
	modulate.a = 0.5
	bar.modulate.a = 0.5
	bar.value = _get_volume()
	volume = _get_volume()
	_update_volume()


func _input(event: InputEvent) -> void:
	if not focused:
		return
	if not event is InputEventMouseButton:
		return
	if not event.is_pressed():
		return
	var multiplier: float = 1.0 if not Input.is_key_pressed(KEY_SHIFT) else 0.2
	match event.button_index:
		MOUSE_BUTTON_LEFT:
			AudioServer.set_bus_mute(0, not AudioServer.is_bus_mute(0))
		MOUSE_BUTTON_WHEEL_UP:
			volume = minf(volume + 5.0 * multiplier, 100.0)
		MOUSE_BUTTON_WHEEL_DOWN:
			volume = maxf(volume - 5.0 * multiplier, 0.0)
		_:
			pass
	
	Config.set_value('app', 'mute', AudioServer.is_bus_mute(0))
	Config.set_value('app', 'volume', volume)
	bar.value = volume
	_update_volume()
	_update_icon()


func _get_volume() -> float:
	return db_to_linear(AudioServer.get_bus_volume_db(0)) * 100.0


func _update_volume() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(volume / 100.0))


func _update_icon() -> void:
	if AudioServer.is_bus_mute(0):
		texture = VOLUME_OFF
		return
	
	var volume := _get_volume()
	texture = VOLUME_UP if volume > 25.0 else VOLUME_DOWN


func _on_mouse_entered() -> void:
	focused = true
	bar.visible = true
	_reset_tween()
	tween = tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(self, 'modulate:a', 1.0, 0.75)
	tween.tween_property(bar, 'modulate:a', 1.0, 0.75)


func _on_mouse_exited() -> void:
	focused = false
	_reset_tween()
	tween = tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(self, 'modulate:a', 0.5, 0.75)
	tween.tween_property(bar, 'modulate:a', 0.5, 0.75)


func _reset_tween() -> void:
	if is_instance_valid(tween) and tween.is_running():
		tween.kill()
	
	tween = create_tween()
