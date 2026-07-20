extends CharacterBody3D

@export var speed: float = 8.0
@export var acceleration: float = 10.0
@export var mouse_sensitivity: float = 0.003

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event : InputEvent):
	if event is InputEventMouseMotion:
		if(Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED):
			return
		rotate_y(-event.relative.x * mouse_sensitivity)
		rotate_object_local(Vector3(1, 0, 0), -event.relative.y * mouse_sensitivity)
	if event is InputEventMouseButton:
		if(event.button_index == MOUSE_BUTTON_LEFT):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if(event.button_index == MOUSE_BUTTON_RIGHT):
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	var input_dir = Input.get_vector("a", "d", "w", "s")
	var move_axis = 0.0

	var direction = (transform.basis * Vector3(input_dir.x, move_axis, input_dir.y)).normalized()
	
	velocity = velocity.lerp(direction * speed, acceleration * delta)
	move_and_slide()
