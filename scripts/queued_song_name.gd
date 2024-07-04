extends Label


@onready var timer: Timer = $timer
@onready var artist_name: Label = %artist_name

var state: SongLabelState = SongLabelState.WAITING_DOWN
var original_text: String = ''
var index: int = 0
var started: bool = false


func _process(delta: float) -> void:
	if position.x < 4.0 and not started:
		started = true
		position.x = 4.0
		original_text = text.strip_edges().strip_escapes()
		timer.start()


func _tick() -> void:
	match state:
		SongLabelState.WAITING_DOWN:
			state = SongLabelState.DOWN
		SongLabelState.WAITING_UP:
			state = SongLabelState.UP
		SongLabelState.DOWN:
			if index < original_text.length() + 1:
				index += 1
			else:
				state = SongLabelState.WAITING_UP
		SongLabelState.UP:
			if index > 0:
				index -= 1
			if index == 0:
				state = SongLabelState.WAITING_DOWN
	
	size.x = 0.0
	text = original_text.substr(index)
	position.x = 4.0
	
	if state == SongLabelState.DOWN and size.x <= artist_name.size.x:
		state = SongLabelState.WAITING_UP


enum SongLabelState {
	DOWN = 0x00,
	WAITING_DOWN = 0x10,
	UP = 0x01,
	WAITING_UP = 0x11,
}
