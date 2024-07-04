extends Button

const REPEAT := preload('res://assets/images/icons/repeat.svg')
const REPEAT_ONE := preload('res://assets/images/icons/repeat_one.svg')

var target_alpha: float = 0.5


func _ready() -> void:
	# update here so it updates properly
	NowPlaying.loop_mode = Config.get_value('app', 'loop_mode')
	update()


func _process(delta: float) -> void:
	modulate.a = lerpf(modulate.a, target_alpha, delta * 6.0)


func update():
	match NowPlaying.loop_mode:
		NowPlaying.LoopMode.LOOP_SINGLE:
			icon = REPEAT_ONE
			target_alpha = 0.9
		NowPlaying.LoopMode.LOOP_QUEUE:
			icon = REPEAT
			target_alpha = 0.9
		_:
			icon = REPEAT
			target_alpha = 0.5


func _on_pressed() -> void:
	NowPlaying.loop_mode = wrapi(NowPlaying.loop_mode + 1, 0, NowPlaying.LoopMode.size())
	Config.set_value('app', 'loop_mode', NowPlaying.loop_mode)
	update()
