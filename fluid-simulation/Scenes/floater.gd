class_name Floaty extends RigidBody3D

var sorounding_fluid : Fluid
const buoyancy : float = 3.0
const damping_strength : float = 0.3

func _process(_delta: float) -> void:
	if(!sorounding_fluid): return
	
	#calculate wave height at balls position and depth of ball
	var wave_height : float = sorounding_fluid.get_current_wave_height(global_position, sorounding_fluid.amplitude, sorounding_fluid.steepness, sorounding_fluid.wavelength)
	var ball_depth : float = wave_height - global_position.y + 1.0
	
	if(ball_depth > 0):
		#apply force upwards with damping to stop it at surface
		var force_strength : float = ball_depth * buoyancy
		var damping_force : float = -linear_velocity.y * damping_strength
		apply_central_force(Vector3.UP * (force_strength + damping_force))


#helper methods to allow physics updates from the fluid inside this object
func attach_fluid(fluid : Fluid):
	sorounding_fluid = fluid

func detach_fluid():
	sorounding_fluid = null
