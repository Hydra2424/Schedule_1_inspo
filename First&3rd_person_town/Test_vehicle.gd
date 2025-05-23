extends VehicleBody3D


@export var MAX_STEER = 0.9
@export var ENGINE_POWER = 300

var used = false
@onready var Driver_seat = $Driver_seat_node.transform
var Vehicle_on = false
var Driver = null


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
	if event.is_action_pressed("Interact_key") and used == true:
		used = false
		
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if used == true:
		steering = move_toward(steering, Input.get_axis("Move_right", "Move_left") * MAX_STEER, delta * 10)
		engine_force = Input.get_axis("Move_backward","Move_forward") * ENGINE_POWER
		$Camera3.make_current()

func _turn_vehicle_on():
	Vehicle_on = true
	$Left_headlight/SpotLight3D2.visible = true
	$Right_headlight/SpotLight3D.visible = true
	
	


func _start_vehicle():
	_turn_vehicle_on()
	used = true
