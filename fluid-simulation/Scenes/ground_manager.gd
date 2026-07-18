extends MeshInstance3D

@onready var caustic_light_source : DirectionalLight3D = $"../DirectionalLight3D"

var ground_material : ShaderMaterial
var time : float

func _ready() -> void:
	ground_material = self.get_surface_override_material(0)
	
	var caustic_tex = load("res://caustic_texture.jpg")
	ground_material.set_shader_parameter("caustic_texture", caustic_tex)
	ground_material.set_shader_parameter("light_direction", -caustic_light_source.global_transform.basis.z.normalized())

func _process(delta: float) -> void:
	time += delta
	ground_material.set_shader_parameter("time", time)

func _on_amplitude_changed(value : float):
	ground_material.set_shader_parameter("wave_amplitude", value)

func _on_steepness_changed(value : float):
	ground_material.set_shader_parameter("wave_steepness", value)

func _on_wavelength_changed(value : float):
	ground_material.set_shader_parameter("wave_length", value)
