extends Camera3D

@onready var fluid = $"../../Fluid"

@export var target: Vector3 = Vector3.ZERO
@export var distance: float = 2.0
@export var sensitivity: float = 0.3
@export var min_pitch: float = -80.0
@export var max_pitch: float = 80.0

var _yaw: float = 0.0
var _pitch: float = 0.0
var _is_orbiting: bool = false

var underwater: bool = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_is_orbiting = event.pressed
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			distance = max(1.0, distance - 0.5)
			_update_camera()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			distance = min(20.0, distance + 0.5)
			_update_camera()
	
	if event is InputEventMouseMotion and _is_orbiting:
		_yaw -= event.relative.x * sensitivity
		_pitch -= event.relative.y * sensitivity
		_pitch = clamp(_pitch, min_pitch, max_pitch)
		_update_camera()


func _update_camera() -> void:
	var yaw_rad: float = deg_to_rad(_yaw)
	var pitch_rad: float = deg_to_rad(_pitch)
	
	var offset: Vector3 = Vector3(
		cos(pitch_rad) * sin(yaw_rad),
		sin(pitch_rad),
		cos(pitch_rad) * cos(yaw_rad)
	) * distance
	
	get_parent().global_position = target + offset
	global_position = target + offset
	look_at(target, Vector3.UP)

func _process(_delta: float) -> void:
	underwater = fluid.is_under_water(global_transform.origin)
	print(underwater)
