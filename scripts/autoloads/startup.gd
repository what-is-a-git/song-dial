## Class that runs once on startup and frees itself.
extends Node


func _ready() -> void:
	PhysicsServer2D.set_active(false)
	PhysicsServer3D.set_active(false)
	NavigationServer3D.set_active(false)
	get_window().min_size = Vector2i(640, 320)
	queue_free()
