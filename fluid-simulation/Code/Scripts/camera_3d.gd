extends Camera3D

@onready var fluid = $"../../Fluid"
@onready var filter : MeshInstance3D = $MeshInstance3D
@onready var physics_parent : CharacterBody3D = $".."
var underwater: bool = false

#do a check in fluid to see if we apply the underwater filter or not
func _process(_delta: float) -> void:
	underwater = fluid.is_under_water(physics_parent.global_transform.origin)
	filter.visible = underwater;
