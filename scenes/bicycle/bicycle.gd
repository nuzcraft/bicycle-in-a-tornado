extends KinematicBody2D
class_name Bicycle

export(int) var ACCELERATION = 150
export(int) var FRICTION = 400
export(int) var MAX_SPEED = 1000
export(int) var ROTATION_SPEED = 10
export(int) var MAX_ROTATION_DEGREES = 90

enum {
	MOVE,
}

var velocity = Vector2.ZERO
var state = MOVE

var next_capture_pos = Vector2(-20, -45)
var capture_pos_iterator = 0
var captured_items = []
var obj_z_index = 10

func _ready():
	pass 

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state: 
		MOVE: move_state(input, delta)
		
func move_state(input, delta):
	
	apply_friction(input, delta)
	apply_acceleration(input, delta)
	apply_rotation(input, delta)
	velocity = move_and_slide(velocity, Vector2.UP)
	
func apply_friction(input, delta):
	if input.x == 0:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	if input.y == 0:
		velocity.y = move_toward(velocity.y, 0, FRICTION * delta)
	
func apply_acceleration(input, delta):
	velocity.x += ACCELERATION * delta * input.x
	velocity.y += ACCELERATION * delta * input.y
	if velocity.x > MAX_SPEED:
		velocity.x = MAX_SPEED
	if velocity.y > MAX_SPEED:
		velocity.y = MAX_SPEED
		
func apply_rotation(input, delta):
	rotation_degrees += ROTATION_SPEED * delta * input.x
	rotation_degrees = clamp(rotation_degrees, -MAX_ROTATION_DEGREES, MAX_ROTATION_DEGREES)
	
func capture_item(obj):
	captured_items.append(obj)
	if capture_pos_iterator < 4:
		next_capture_pos += Vector2(-10, 0)
		capture_pos_iterator += 1
	else:
		next_capture_pos += Vector2(40, -10)
		capture_pos_iterator = 0
		obj_z_index -= 1
	obj.z_index = obj_z_index
