extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
@onready var animation_tree = $AnimationTree
@onready var armature = $character/Armature

@onready var joystick = $GUI/Joystick
@onready var jump = $GUI/Jump
@onready var object_detector = $ObjectDetector
@onready var drive_btn = $GUI/DriveBtn

var jumping: bool

var is_in_vehicle: bool = false
var accessible_vehicle


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	set_platform_config()
	

func _physics_process(delta):
	if !is_in_vehicle:
		if not is_on_floor():
			velocity.y -= gravity * delta

		# Handle Jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			jumping = true
			velocity.y = JUMP_VELOCITY
		else:
			jumping = false


		var input_dir
		
		if OS.get_name() == "Windows":
			input_dir = Input.get_vector("left", "right", "forward", "backward")
		else:
			input_dir = joystick.get_direction()

		var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		direction =  direction.rotated(Vector3.UP, get_tree().get_nodes_in_group('camera_pivot')[0].rotation.y)
		var sprint_factor = 1
		if direction:
			if Input.is_action_pressed("sprint"):
				sprint_factor = 2
			armature.rotation.y = lerp_angle(armature.rotation.y, atan2(velocity.x, velocity.z), 0.15)
			velocity.x = direction.x * SPEED*sprint_factor
			velocity.z = direction.z * SPEED*sprint_factor
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)

		move_and_slide()
		handle_animations(input_dir)
		detect_vehicles()
	if Input.is_action_just_pressed("toggle_car"):
		if is_in_vehicle:
			get_out()
		else:
			get_in()
			
func detect_vehicles():
	var current_objects = object_detector.get_overlapping_bodies()
	current_objects = current_objects.filter(func(obj):
		return obj.is_in_group("vehicle")
		)
	if current_objects.size() > 0:
		accessible_vehicle = current_objects[0]
		show_drive_btn(true)
	else:
		show_drive_btn(false)
		accessible_vehicle = null
		
func handle_animations(input_dir):
	animation_tree.set("parameters/conditions/idle", input_dir==Vector2.ZERO && is_on_floor() && !Input.is_action_pressed("sprint"))
	animation_tree.set("parameters/conditions/walking", input_dir!=Vector2.ZERO && is_on_floor() && !Input.is_action_pressed("sprint"))
	animation_tree.set("parameters/conditions/jump", jumping)
	animation_tree.set("parameters/conditions/running", Input.is_action_pressed("sprint") && input_dir!=Vector2.ZERO)

func set_platform_config():
	if OS.get_name() == "Android":
		joystick.show()
		jump.show()
	else:
		joystick.hide()
		jump.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	

func _on_jump_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			if is_on_floor():
				velocity.y = JUMP_VELOCITY
				jumping = true
		else:
			jumping = false


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "jump":
		jumping = false

func set_in_vehicle(a: bool):
	is_in_vehicle = a
	self.visible = !a

func show_drive_btn(a: bool):
	drive_btn.visible = a

func _on_drive_btn_gui_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			get_in()

func get_in():
	if accessible_vehicle:
		accessible_vehicle.has_driver = true
		var player_camera = get_tree().get_first_node_in_group("player_camera")
		var car_camera = accessible_vehicle.camera
		
		set_in_vehicle(true)
		
		car_camera.current = true
		show_drive_btn(false)

func get_out():
	if accessible_vehicle:
		accessible_vehicle.has_driver = false
		var player_camera = get_tree().get_first_node_in_group("player_camera")
		var car_camera = accessible_vehicle.camera
		
		player_camera.current = true
		self.global_position = accessible_vehicle.get_out_pivot.global_position
		
		set_in_vehicle(false)
		
		
