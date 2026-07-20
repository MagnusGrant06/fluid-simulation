extends MeshInstance3D

@onready var caustic_light_source : DirectionalLight3D = $"../DirectionalLight3D"
@onready var obj1 = $"GroundObj1"
@onready var obj2 = $"GroundObj2"
@onready var obj3= $"GroundObj3"
var ground_material : ShaderMaterial

var obj1_mat : ShaderMaterial
var obj2_mat : ShaderMaterial
var obj3_mat : ShaderMaterial
var time : float

func _ready() -> void:
	ground_material = self.get_surface_override_material(0)
	
	obj1_mat = obj1.get_surface_override_material(0)
	obj2_mat = obj2.get_surface_override_material(0)
	obj3_mat = obj3.get_surface_override_material(0)
	
	var caustic_tex = load("res://caustic_texture.jpg")
	ground_material.set_shader_parameter("caustic_texture", caustic_tex)
	ground_material.set_shader_parameter("light_direction", -caustic_light_source.global_transform.basis.z.normalized())
	
	obj1_mat.set_shader_parameter("caustic_texture", caustic_tex)
	obj1_mat.set_shader_parameter("light_direction", -caustic_light_source.global_transform.basis.z.normalized())
	
	obj2_mat.set_shader_parameter("caustic_texture", caustic_tex)
	obj2_mat.set_shader_parameter("light_direction", -caustic_light_source.global_transform.basis.z.normalized())
	
	obj3_mat.set_shader_parameter("caustic_texture", caustic_tex)
	obj3_mat.set_shader_parameter("light_direction", -caustic_light_source.global_transform.basis.z.normalized())

func _process(delta: float) -> void:
	time += delta
	ground_material.set_shader_parameter("time", time)
	obj1_mat.set_shader_parameter("time", time)
	obj2_mat.set_shader_parameter("time", time)
	obj3_mat.set_shader_parameter("time", time)

func _on_amplitude_changed(value : float):
	ground_material.set_shader_parameter("wave_amplitude", value)
	obj1_mat.set_shader_parameter("wave_amplitude",value);
	obj2_mat.set_shader_parameter("wave_amplitude",value);
	obj3_mat.set_shader_parameter("wave_amplitude",value);

func _on_steepness_changed(value : float):
	ground_material.set_shader_parameter("wave_steepness", value)
	obj1_mat.set_shader_parameter("wave_steepness",value);
	obj2_mat.set_shader_parameter("wave_steepness",value);
	obj3_mat.set_shader_parameter("wave_steepness",value);

func _on_wavelength_changed(value : float):
	ground_material.set_shader_parameter("wave_length", value)
	obj1_mat.set_shader_parameter("wave_length",value);
	obj2_mat.set_shader_parameter("wave_length",value);
	obj3_mat.set_shader_parameter("wave_length",value);
