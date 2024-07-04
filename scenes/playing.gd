class_name NowPlaying extends Control


static var queue: Array[SongData] = []
static var index: int = 0
static var loop_mode: LoopMode = LoopMode.OFF
static var instance: NowPlaying = null

@onready var progress_bar: ProgressBar = %progress_bar
@onready var song_name: Label = %song_name
@onready var artist_name: Label = %artist_name
@onready var stream_player := AudioManager.main


func _ready() -> void:
	instance = self
	get_window().files_dropped.connect(_on_files_dropped)
	stream_player.finished.connect(_on_playback_finished)


func _process(delta: float) -> void:
	update_song_display()


func _on_files_dropped(files: PackedStringArray) -> void:
	if not visible:
		return
	
	var empty := queue.is_empty()
	#queue.clear()
	#index = 0
	
	for file in files:
		var data := SongData.new()
		data.path = file
		data.stream = AudioManager.stream_from_file(file)
		data.meta = {}
		queue.push_back(data)
	
	if empty:
		update_current_song()
		update_song_display()
		stream_player.play()
	Queue.instance.update()


func _on_playback_finished() -> void:
	match loop_mode:
		LoopMode.OFF:
			index += 1
			
			if index > queue.size() - 1:
				index = 0
				update_current_song()
				update_song_display()
				return
		LoopMode.LOOP_QUEUE:
			index = wrapi(index + 1, 0, queue.size())
		LoopMode.LOOP_SINGLE:
			pass
		_:
			return
	
	update_current_song()
	update_song_display()
	stream_player.play()


func update_song_display() -> void:
	if not queue.is_empty():
		song_name.text = queue[index].path.get_file().get_basename() + \
				song_name.suffix
		artist_name.text = queue[index].meta.get(&'artist', 'unknown')
	else:
		song_name.text = 'No Song'
		artist_name.text = 'unknown'
	
	if is_instance_valid(stream_player.stream):
		var time := stream_player.get_playback_position()
		progress_bar.max_value = stream_player.stream.get_length()
		progress_bar.value = time
	else:
		progress_bar.max_value = 0.0
		progress_bar.value = 0.0


func update_current_song() -> void:
	if queue.is_empty():
		return
	stream_player.stream = queue[index].stream
	song_name.suffix = ''


class SongData extends RefCounted:
	var path: String
	var stream: AudioStream
	var meta: Dictionary

enum LoopMode {
	OFF = 0,
	LOOP_QUEUE = 1,
	LOOP_SINGLE = 2,
}
