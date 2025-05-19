extends CharacterBody3D

var RAY_LENGTH = 2

const SPEED = 3.0
const JUMP_VELOCITY = 4.5
var FP_camera = true

#bob variables
const BOB_freq = 2.0
const BOB_AMP = 0.1
var t_bob = 0.0
var Incapacitated = false
var no_gravity = false
var Debug_log = true
var map_level = self.get_parent()
var interact_with_vehicle = false
var target_vehicle = null
var interactable_target = null
var Grabbing = null

@export var First_person_sensitibity = 0.01

@onready var head = $Head_node
@onready var camera1 = $Head_node/First_person_cam

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	$Head_node/First_person_cam.make_current()
	
	


func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Incapacitated == false:
		head.rotate_y(-event.relative.x * First_person_sensitibity)
		$Head_node/Grab_point_base.rotate_x(-event.relative.y * First_person_sensitibity)
		$Head_node/Grab_point_base.rotation.x = clamp($Head_node/Grab_point_base.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		camera1.rotate_x(-event.relative.y * First_person_sensitibity)
		camera1.rotation.x = clamp(camera1.rotation.x, deg_to_rad(-80), deg_to_rad(80))
		
	$Head_node/Grab_point_base/Grab_point.transform.origin.z = (-1 * RAY_LENGTH)

	if Input.is_action_just_pressed("Toggle_camera_mode"):
		if FP_camera == true:
			FP_camera = false
			$SpringArm3D/Third_person_cam.make_current()
		else:
			FP_camera = true
			$Head_node/First_person_cam.make_current()
	
	#left click interact
	if event.is_action_pressed("Left_Mouse_Click") and interactable_target != null:
		interactable_target.global_transform = $Head_node/Grab_point_base/Grab_point.global_transform
		Grabbing = interactable_target
	#just released the mouse
	if event.is_action_released("Left_Mouse_Click"):
		Grabbing = null
	
	if event.is_action_pressed("wheel_up") and FP_camera == true:
		RAY_LENGTH += 0.2
	if event.is_action_pressed("wheel_down") and FP_camera == true:
		RAY_LENGTH -= 0.2
	




func _physics_process(delta):
	
	
	if Debug_log == true:
		$Debug_Label.text = str(RAY_LENGTH)
	
	
	if Grabbing != null:
		Grabbing.global_transform = $Head_node/Grab_point_base/Grab_point.global_transform
	
	
	# Add the gravity.
	if not is_on_floor() and no_gravity == true:
		velocity.y -= gravity * delta

	#ray cast
	var space_state = get_world_3d().direct_space_state
	var cam = camera1
	var mousepos = get_viewport().get_mouse_position()
	
	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * RAY_LENGTH
	var query = PhysicsRayQueryParameters3D.create(origin, end)
	query.collide_with_areas = true
	
	var result = space_state.intersect_ray(query)
	
	
	if result.size() > 0:
		var ray_coll = result.collider
		if ray_coll.is_in_group("interactable"):
			$Interact_label.text = "Interact"
			interactable_target = ray_coll
		if ray_coll.is_in_group("vehicle"):
			$Interact_button.visible = true
			interact_with_vehicle = true
			target_vehicle = result.collider
		
		
	else:
		$Interact_label.text = ""
		$Interact_button.visible = false
		interact_with_vehicle = false
		interactable_target = null
	
	# Interacting with objects
	if Input.is_action_just_pressed("Interact_key"):
		
		if interact_with_vehicle == true:
			Incapacitated = true
			no_gravity = false
			target_vehicle._start_vehicle()
			transform = target_vehicle.Driver_seat
			#self.reparent(target_vehicle)
	
	


	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and Incapacitated == false:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if  Incapacitated == false:
		var input_dir = Input.get_vector("Move_left", "Move_right", "Move_forward", "Move_backward")
		var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
	
	
	# head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera1.transform.origin = _headbob(t_bob)
	
	
	
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_freq) * BOB_AMP
	return pos
