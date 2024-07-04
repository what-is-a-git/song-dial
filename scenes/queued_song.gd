extends Panel


@onready var song_name: Label = %song_name
@onready var artist_name: Label = %artist_name

var song_data: NowPlaying.SongData = null


func _ready() -> void:
	display()


func display() -> void:
	if not is_instance_valid(song_data):
		return
	
	song_name.text = song_data.path.get_file().get_basename()
	artist_name.text = song_data.meta.get(&'artist', 'unknown')


func _on_play_pressed() -> void:
	NowPlaying.index = NowPlaying.queue.find(song_data)
	NowPlaying.instance.update_current_song()
	NowPlaying.instance.update_song_display()
	AudioManager.main.play()


func _on_remove_pressed() -> void:
	queue_free()
	
	var last := NowPlaying.queue[NowPlaying.index]
	NowPlaying.queue.erase(song_data)
	
	if NowPlaying.queue.is_empty():
		AudioManager.main.stream = null
		AudioManager.main.stream_paused = false
		AudioManager.main.stop()
		return
	
	var playing := AudioManager.main.playing
	if playing and last == song_data:
		NowPlaying.index = clampi(NowPlaying.index, 0, NowPlaying.queue.size() - 1)
		NowPlaying.instance.update_current_song()
		AudioManager.main.seek(0.0)
		AudioManager.main.play()
	else:
		NowPlaying.index = NowPlaying.queue.find(last)
	
	NowPlaying.instance.update_song_display()
