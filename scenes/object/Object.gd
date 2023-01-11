extends RigidBody2D

signal collided

export(float) var MAX_INITIAL_TORQUE = 1500.0
export(int) var MIN_INITIAL_IMPULSE = -300
export(int) var MAX_INITIAL_IMPULSE = -100
export(float) var MAX_ANGULAR_VELOCITY = 12.0

var rng = RandomNumberGenerator.new()
var captured = false

func _ready():
	rng.randomize()
	
	var impulse_x = rng.randi_range(MIN_INITIAL_IMPULSE, MAX_INITIAL_IMPULSE)
	var impulse_y = rng.randf_range(-50, 50)
	var torque = rng.randf_range(-MAX_INITIAL_TORQUE, MAX_INITIAL_TORQUE)
	apply_central_impulse(Vector2(impulse_x, impulse_y))
	add_torque(torque)

func _process(_delta):
	if get_angular_velocity() > MAX_ANGULAR_VELOCITY:
		set_angular_velocity(MAX_ANGULAR_VELOCITY)
		add_torque(0.0)
	if get_angular_velocity() < -MAX_ANGULAR_VELOCITY:
		set_angular_velocity(-MAX_ANGULAR_VELOCITY)
		add_torque(0.0)

func _on_Object_body_entered(body):
	emit_signal("collided", self, body)
	
