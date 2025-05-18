extends CharacterBody3D


const SPEED = 3.0
const JUMP_VELOCITY = 4.5
var FP_camera = true

#bob variables
const BOB_freq = 2.0
const BOB_AMP = 0.28
var t_bob = 0.0


@export var First_person_sensitibity = 0.02

@onready var head = $Head_node
@onready var camera1 = $Head_node/First_person_cam

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")




func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		head.rotate_y(-event.relative.x * First_person_sensitibity)
		
		camera1.rotate_x(-event.relative.y * First_person_sensitibity)
		camera1.rotation.x = clamp(camera1.rotation.x, deg_to_rad(-40), deg_to_rad(60))

	if Input.is_action_just_pressed("Toggle_camera_mode") and FP_camera == true:
		FP_camera = false
		$SpringArm3D/Third_person_cam.make_current()
	else:
		FP_camera = true
		$Head_node/First_person_cam.make_current()


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta




	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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


