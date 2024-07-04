extends Button


@export_enum('Back', 'Forward') var direction: int = 0


func _on_pressed() -> void:
	if NowPlaying.queue.is_empty():
		return
	if NowPlaying.queue.size() < 2:
		return
	
	var player := NowPlaying.instance.stream_player
	var is_playing := player.playing
	var movement := (1.0 - (direction * 2.0))
	var new_index := wrapi(NowPlaying.index - movement, 0, NowPlaying.queue.size())
	
	NowPlaying.index = new_index
	NowPlaying.instance.update_current_song()
	NowPlaying.instance.update_song_display()
	
	if is_playing:
		player.play()
