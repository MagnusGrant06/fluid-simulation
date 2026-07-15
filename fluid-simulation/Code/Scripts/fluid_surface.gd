extends MeshInstance3D

@onready var environment : WorldEnvironment = $"../WorldEnvironment"
@onready var camera : Camera3D = $"../Camera3D"
var material: ShaderMaterial = self.get_active_material(0)

func _ready() -> void:
	material.set_shader_parameter("sky_texture", environment.environment.sky.sky_material.panorama)
