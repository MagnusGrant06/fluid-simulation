extends Node3D

@onready var camera : Camera3D = $CharacterBody3D/Camera3D

const floaty_sphere = preload("res://Scenes/floater.tscn")

func _input(event: InputEvent) -> void:
	#spawn physics sphere at mouse to show off water physics
	if(event.is_action_pressed("space")):
		var camera_space : Vector3 = camera.project_position(get_viewport().get_mouse_position(),5.0)
		var floaty_instance = floaty_sphere.instantiate()
		add_child(floaty_instance)
		floaty_instance.global_position = camera_space
