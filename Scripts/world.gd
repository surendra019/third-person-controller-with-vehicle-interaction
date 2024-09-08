extends Node3D
@onready var pause = $GUI/Pause


func _physics_process(delta):
	if Input.is_action_just_pressed("pause"):
		pause.show()
