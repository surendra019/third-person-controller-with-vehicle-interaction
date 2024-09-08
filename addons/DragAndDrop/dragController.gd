extends Node

signal released(pos)

var parent
@export var ReturnToStart : bool = true

var pos_locked
var touch_pos
var entered = false


func _ready():
	
	parent = self.get_parent()
	if not parent is Control:
		printerr("Error: parent is not a control node")
	else:
		#init_pos = parent.global_position
		parent.gui_input.connect(_on_gui_input)

func _on_gui_input(event):
	
	if parent is Control:
		if event is InputEventScreenDrag:
			if !pos_locked:
				if touch_pos!=Vector2.ZERO:
					#parent.show_shadow(true)
					#print(abs(parent.max_distance))
					if touch_pos!=null:
						var dir = (event.position).normalized()
						print(event.position.normalized())
						#print(parent.center.distance_to(parent.global_position+parent.size/2))
						if parent.center.distance_to(parent.global_position+parent.size/2)<=parent.max_distance:
							parent.position += (event.position-touch_pos)*parent.scale
						#else:
							#parent.global_position.x = parent.center.x+cos(angle)*parent.max_distance
							#parent.global_position.y = parent.center.y+sin(angle)*parent.max_distance
							
						#parent.position = parent.max_distance*parent.center.direction_to(event.position)
				
		if event is InputEventScreenTouch:
			touch_pos = event.position
			
			if !event.pressed:
				emit_signal("released", parent.position)
				if !entered:
					if ReturnToStart:
						var twn = get_tree().create_tween()
						twn.tween_property(parent, "position", parent.init_pos, .1)
						twn.play()
						#parent.show_shadow(false)
						#parent.z_index = parent.init_z_index
				
						#parent.position = init_pos
