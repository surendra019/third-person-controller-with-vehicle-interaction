@tool
extends EditorPlugin


func _enter_tree():
	add_custom_type("DragController2D", "Node", preload("res://addons/DragAndDrop/dragController.gd"), preload("res://addons/DragAndDrop/ic.png"))



func _exit_tree():
	remove_custom_type("DragController2D")
	pass
