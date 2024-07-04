extends Node


const EXTENSIONS: PackedStringArray = ['mp3', 'ogg', 'wav', 'flac']
@onready var main: AudioStreamPlayer = %main


func _ready() -> void:
	AudioServer.set_bus_mute(0, Config.get_value('app', 'mute'))
	AudioServer.set_bus_volume_db(0, 
			linear_to_db(Config.get_value('app', 'volume') / 100.0))


func stream_from_file(file: String) -> AudioStream:
	var path_type := _file_type(file)
	if path_type == AudioFormat.NONE:
		return null
	
	var stream: AudioStream
	match path_type:
		AudioFormat.MP3:
			var mp3 := AudioStreamMP3.new()
			mp3.data = FileAccess.get_file_as_bytes(file)
			stream = mp3
		AudioFormat.OGG:
			var ogg := AudioStreamOggVorbis.load_from_file(file)
			stream = ogg
		AudioFormat.WAVE:
			stream = WAVImporter.parse_wave(FileAccess.get_file_as_bytes(file)).unwrap()
		AudioFormat.FLAC:
			stream = AudioStreamFLAC.load_from_file(file)
		_:
			printerr('File of type %s not implemented yet!' % \
					[AudioFormat.find_key(path_type)])
	
	return stream


func _file_type(input: String) -> AudioFormat:
	if not FileAccess.file_exists(input):
		return AudioFormat.NONE
	# do this *after* because OSes other than windows exist
	input = input.to_lower()
	
	for ext in EXTENSIONS:
		if input.ends_with('.%s' % ext):
			return EXTENSIONS.find(ext)
	
	return AudioFormat.NONE

enum AudioFormat {
	NONE = -1,
	MP3 = 0,
	OGG = 1,
	WAVE = 2,
	FLAC = 3,
}
