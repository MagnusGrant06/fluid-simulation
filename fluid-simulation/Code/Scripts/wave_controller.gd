extends Control

@onready var amp_slider : HSlider = $VBoxContainer/AmplitudeSlider
@onready var steep_slider : HSlider = $VBoxContainer/SteepnessSlider
@onready var wavlen_slider : HSlider = $VBoxContainer/WavelengthSlider

@onready var fluid : MeshInstance3D = $"../FluidCube"
var fluid_material : ShaderMaterial

func _ready() -> void:
	amp_slider.connect("value_changed", _on_amplitude_changed)
	steep_slider.connect("value_changed", _on_steepness_changed)
	wavlen_slider.connect("value_changed", _on_wavelength_changed)
	
	fluid_material = fluid.get_active_material(0)

func _on_amplitude_changed(value : float):
	fluid_material.set_shader_parameter("wave_amplitude", value)

func _on_steepness_changed(value : float):
	fluid_material.set_shader_parameter("wave_steepness", value)

func _on_wavelength_changed(value : float):
	fluid_material.set_shader_parameter("wave_length", value)
