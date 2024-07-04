extends Button


func _on_pressed() -> void:
	if NowPlaying.queue.is_empty():
		return
	if NowPlaying.queue.size() < 2:
		return
	
	randomize()
	
	var player := NowPlaying.instance.stream_player
	var is_playing := player.playing
	var current := NowPlaying.queue[NowPlaying.index]
	
	while NowPlaying.queue[NowPlaying.index] == current:
		NowPlaying.queue.shuffle()
		NowPlaying.index = 0
	
	NowPlaying.instance.update_current_song()
	NowPlaying.instance.update_song_display()
	if is_playing:
		player.play()
	
	Queue.instance.update()
