class_name SettingChecKBox extends CheckBox


@export var setting: StringName = &'always_show_settings'


func _ready() -> void:
	button_pressed = Config.get_value('app', setting)


func _on_toggled(toggled_on: bool) -> void:
	Config.set_value('app', setting, toggled_on)
