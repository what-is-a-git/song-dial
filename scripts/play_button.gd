extends Button


const PAUSE := preload('res://assets/images/icons/pause.svg')
const PLAY_ARROW := preload('res://assets/images/icons/play_arrow.svg')

@onready var player := AudioManager.main


func _process(delta: float) -> void:
	_update_icon()


func _on_pressed() -> void:
	if not player.playing:
		player.play(player.get_playback_position())
	else:
		player.stream_paused = not player.stream_paused
	_update_icon()


func _update_icon() -> void:
	if not player.playing:
		icon = PLAY_ARROW
		return
	
	icon = PLAY_ARROW if player.stream_paused else PAUSE
