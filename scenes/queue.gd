class_name Queue extends Control


const QUEUED_SONG := preload('res://scenes/queued_song.tscn')
static var instance: Queue = null

@onready var vbox: VBoxContainer = %vbox
var target_alpha: float = 0.0


func _ready() -> void:
	instance = self
	modulate.a = target_alpha
	update()


func _process(delta: float) -> void:
	modulate.a = lerpf(modulate.a, target_alpha, delta * 8.0)
	visible = modulate.a > 0.01


func toggle() -> void:
	target_alpha = 1.0 - target_alpha


func update() -> void:
	if NowPlaying.queue.is_empty():
		return
	
	for child in vbox.get_children():
		child.queue_free()
	
	for data in NowPlaying.queue:
		var song := QUEUED_SONG.instantiate()
		song.song_data = data
		vbox.add_child(song)


func _on_clear_pressed() -> void:
	for child in vbox.get_children():
		child.queue_free()
	
	AudioManager.main.stop()
	AudioManager.main.stream = null
	AudioManager.main.stream_paused = false
	
	NowPlaying.queue.clear()
	NowPlaying.instance.update_current_song()
	NowPlaying.instance.update_song_display()
