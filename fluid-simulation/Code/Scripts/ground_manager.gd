extends MeshInstance3D

@onready var caustic_light_source : DirectionalLight3D = $"../DirectionalLight3D"
@onready var obj1 = $"GroundObj1"
@onready var obj2 = $"GroundObj2"
@onready var obj3= $"GroundObj3"

var ground_material : ShaderMaterial = ShaderMaterial.new()
var time : float

func _ready() -> void:
	ground_material.shader = load("res://Code/Shaders/ground.gdshader")
	
	#share same shader across all ground objects, as we want the same effect on all
	self.material_override = ground_material
	obj1.material_override = ground_material
	obj2.material_override = ground_material
	obj3.material_override = ground_material
	
	var caustic_tex = load("res://assets/caustic_texture.jpg")
	ground_material.set_shader_parameter("caustic_texture", caustic_tex)
	ground_material.set_shader_parameter("light_direction", -caustic_light_source.global_transform.basis.z.normalized())

#set time accurately across anything to do with waves
func _process(delta: float) -> void:
	time += delta
	ground_material.set_shader_parameter("time", time)

#set values using sliders
func _on_amplitude_changed(value : float):
	ground_material.set_shader_parameter("wave_amplitude", value)

func _on_steepness_changed(value : float):
	ground_material.set_shader_parameter("wave_steepness", value)

func _on_wavelength_changed(value : float):
	ground_material.set_shader_parameter("wave_length", value)
