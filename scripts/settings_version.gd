extends Label


func _ready() -> void:
	text = text.replace('$VERSION', 
			ProjectSettings.get_setting('application/config/version', '?.?.?'))
