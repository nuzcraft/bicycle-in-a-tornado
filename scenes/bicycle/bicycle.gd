extends KinematicBody2D
class_name Bicycle

signal release_object

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
	
func capture_object(obj):
	obj.captured = true
	obj.collided = true
	var dist = global_position.distance_to(obj.global_position)
	var angle =  global_position.direction_to(obj.global_position).angle()
	var new_angle = Vector2(cos(-rotation + angle), sin(-rotation + angle))
	var new_pos = dist * new_angle
	obj.mode = obj.MODE_KINEMATIC
	obj.get_parent().remove_child(obj)
	add_child(obj)
	obj.position = new_pos
	var next_pos = next_capture_pos
	captured_items.append(obj)
	if capture_pos_iterator < 4:
		next_capture_pos += Vector2(-10, 0)
		capture_pos_iterator += 1
	else:
		next_capture_pos += Vector2(40, -10)
		capture_pos_iterator = 0
		obj_z_index -= 1
	obj.z_index = obj_z_index
	var tween = get_tree().create_tween()
	tween.tween_property(obj, "position", next_pos, 0.25)
	tween.parallel().tween_property(obj, "rotation_degrees", 0.0, 0.25)
	
func release_object():
	if not captured_items.empty():
		var obj = captured_items.pop_back()
		obj.captured = false
		emit_signal("release_object", obj)
