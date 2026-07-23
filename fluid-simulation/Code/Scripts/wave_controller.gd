extends Control



@onready var amp_slider : HSlider = $VBoxContainer/AmplitudeSlider
@onready var steep_slider : HSlider = $VBoxContainer/SteepnessSlider
@onready var wavlen_slider : HSlider = $VBoxContainer/WavelengthSlider
@onready var vis_slider : HSlider = $VBoxContainer/VisibilitySlider
@onready var god_slider : HSlider = $VBoxContainer/GodRaySlider

@onready var sun : DirectionalLight3D = $"../DirectionalLight3D"
@onready var fluid : Node3D = $"../Fluid"
@onready var camera_filter : MeshInstance3D = $"../CharacterBody3D/Camera3D/MeshInstance3D"
@onready var ground : MeshInstance3D = $"../Ground"

var fluid_material : ShaderMaterial
var bottom_fluid_material : ShaderMaterial
var filter_material : ShaderMaterial

#manually connect methods to signals as i dont like the gui
func _ready() -> void:
	amp_slider.connect("value_changed", _on_amplitude_changed)
	steep_slider.connect("value_changed", _on_steepness_changed)
	wavlen_slider.connect("value_changed", _on_wavelength_changed)
	vis_slider.connect("value_changed", _on_visibility_changed)
	god_slider.connect("value_changed", _on_god_ray_changed)
	
	amp_slider.connect("value_changed", ground._on_amplitude_changed)
	steep_slider.connect("value_changed", ground._on_steepness_changed)
	wavlen_slider.connect("value_changed", ground._on_wavelength_changed)
	
	fluid_material = fluid.surface.get_active_material(0)
	filter_material = camera_filter.get_active_material(0)
	bottom_fluid_material = fluid.below_surface.get_active_material(0)
	
	filter_material.set_shader_parameter("sun_direction", -sun.global_transform.basis.z.normalized())

#straightforward methods to change wave paramaters for presentation 
func _on_amplitude_changed(value : float):
	fluid_material.set_shader_parameter("wave_amplitude", value)
	bottom_fluid_material.set_shader_parameter("wave_amplitude", value)
	fluid.amplitude = value

func _on_steepness_changed(value : float):
	fluid_material.set_shader_parameter("wave_steepness", value)
	bottom_fluid_material.set_shader_parameter("wave_steepness", value)
	fluid.steepness = value

func _on_wavelength_changed(value : float):
	fluid_material.set_shader_parameter("wave_length", value)
	bottom_fluid_material.set_shader_parameter("wave_length", value)
	fluid.wavelength = value

func _on_visibility_changed(value : float):
	fluid_material.set_shader_parameter("visibility",value);
	filter_material.set_shader_parameter("visibility", value);

func _on_god_ray_changed(value : float):
	filter_material.set_shader_parameter("god_ray_strength", value)
