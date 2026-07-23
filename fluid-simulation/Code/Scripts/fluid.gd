class_name Fluid extends Node

@onready var environment : WorldEnvironment = $"../WorldEnvironment"
@onready var camera : Camera3D = $"../CharacterBody3D/Camera3D"
@onready var surface : MeshInstance3D = $AboveSurface
@onready var below_surface : MeshInstance3D = $BelowSurface
@onready var surface_area : Area3D =$Area3D

var wavelength : float = 7.5
var amplitude : float = 0.5
var steepness : float = 0.75
var wave_time : float = 0.0

var within_water_area : bool = false

func _ready() -> void:
	var material: ShaderMaterial = surface.get_active_material(0)
	material.set_shader_parameter("sky_texture", environment.environment.sky.sky_material.panorama)
	surface_area.connect("body_entered", _on_surface_area_entered)
	surface_area.connect("body_exited", _on_surface_area_exited)

#manually keep track of time so its consistent between script and shader
func _process(delta: float) -> void:
	wave_time += delta
	var top_material: ShaderMaterial = surface.get_active_material(0)
	top_material.set_shader_parameter("time", wave_time)
	
	var below_material : ShaderMaterial = below_surface.get_active_material(0)
	below_material.set_shader_parameter("time", wave_time)

#methods to attach / detach the fluid to any floating bodies and check if camera is within water area
func _on_surface_area_entered(body : Node3D):
	if(body is Floaty):
		body.attach_fluid(self)
	if(body.get_child(1) is not Camera3D): return
	within_water_area = true

func _on_surface_area_exited(body : Node3D):
	if(body is Floaty):
		body.detach_fluid()
	if(body.get_child(1) is not Camera3D): return
	within_water_area = false

#check if given point is above or below water surface taking into account waves
func is_under_water(point : Vector3) -> bool:
	if(!within_water_area): return false
	return point.y < get_current_wave_height(point, amplitude, steepness, wavelength)
	

#replicated GDShader code for waves to get waveheight at current given position to check if underwater
func calculate_phase(vertex : Vector3,wave_length : float, direction : Vector2) -> float:
	var k : float = (2.0 * PI) / wave_length
	var angular_freq : float = sqrt(0.3*k)
	var phase : float = (k * (direction.x * vertex.x + direction.y * vertex.z)) - (angular_freq * wave_time)
	return phase

func calculate_wave_offset(position : Vector3, wave_amplitude : float, direction : Vector2, wave_steepness : float, wave_length : float) -> Vector3:
	var phase : float = calculate_phase(position, wave_length, direction)
	var dx : float = (wave_steepness * wave_amplitude * direction.x * cos(phase))
	var dy : float = wave_amplitude * sin(phase)
	var dz : float = (wave_steepness * wave_amplitude * direction.y * cos(phase))
	return Vector3(dx,dy,dz)

func get_current_wave_height(position : Vector3, wave_amplitude : float, wave_steepness : float, wave_length : float) -> float:
	var d1 : Vector3 = calculate_wave_offset(position, wave_amplitude, Vector2(1,0), wave_steepness, wave_length);
	var d2 : Vector3 = calculate_wave_offset(position, wave_amplitude*1.5, Vector2(0,1), wave_steepness*0.75, wave_length*1.5)
	var d3 : Vector3 = calculate_wave_offset(position, wave_amplitude*0.75, Vector2(0.5,0.5), wave_steepness*1.5, wave_length*0.5)
	var d4 : Vector3 = calculate_wave_offset(position, wave_amplitude*0.33, Vector2(-0.5, -0.5), wave_steepness*1.5, wave_length * 0.25)
	
	var d : Vector3 = d1 + d2 + d3 + d4
	return d.y
