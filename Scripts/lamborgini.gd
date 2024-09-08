extends VehicleBody3D

@onready var camera = $CameraPivot/Camera3D
@onready var camera_pivot = $CameraPivot
@onready var get_out_pivot = $GetOutPivot

const POWER = 1000
var has_driver: bool

func _process(delta):
	if has_driver:
		steering = Input.get_axis("right", "left") * 10 
		engine_force = Input.get_axis("backward", "forward") * POWER
		
		camera_pivot.global_position = camera_pivot.global_position.lerp(global_position, delta * 5)
		camera_pivot.rotation_degrees = camera_pivot.rotation_degrees.lerp(rotation_degrees, delta * 5)
