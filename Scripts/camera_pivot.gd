extends Node3D
@onready var control = $Control

var player
var sensi = 5

func _ready():
	player = get_tree().get_nodes_in_group('player')[0]
	if OS.get_name() == "Android":
		control.gui_input.connect(g_in)

func _physics_process(delta):
	self.global_position = player.global_position

func _input(event):
	if !player.is_in_vehicle:
		if event is InputEventMouseMotion:
			rotation.x = clamp(rotation.x-event.relative.y/1000*sensi, -0.9, 0.62)
			rotation.y -= event.relative.x/1000*sensi
		
func g_in(event):
	if event is InputEventScreenDrag:
		rotation.x = clamp(rotation.x-event.relative.y/1000*sensi, -0.9, 0.62)
		rotation.y -= event.relative.x/1000*sensi
