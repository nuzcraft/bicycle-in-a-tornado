extends Node

onready var camera_pos = $Camera2D.global_position
onready var camera_bounds = {
	"top": camera_pos.y - Game.size.y / 2,
	"bottom": camera_pos.y + Game.size.y / 2,
	"left": camera_pos.x - Game.size.x / 2,
	"right": camera_pos.x + Game.size.x / 2,
}
onready var bicycle = $Bicycle

var elapsed = 0
var collectable_scene = preload("res://scenes/collectable/collectable.tscn")
var obstacle_scene = preload("res://scenes/obstacle/obstacle.tscn")
var rng = RandomNumberGenerator.new()

# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
func pre_start(params):
	rng.randomize()
	var cur_scene: Node = get_tree().current_scene
	print("Current scene is: ", cur_scene.name, " (", cur_scene.filename, ")")
	print("gameplay.gd: pre_start() called with params = ")
	if params:
		for key in params:
			var val = params[key]
			printt("", key, val)
	$Bicycle.position = Game.size / 2
	print("Processing...")
	yield(get_tree().create_timer(2), "timeout")
	print("Done")


# `start()` is called when the graphic transition ends.
func start():
	print("gameplay.gd: start() called")


func _process(delta):
	elapsed += delta
	bicycle_wiggle()
	bicycle_clamp_on_screen()	

func bicycle_wiggle():
	bicycle.global_position.x += 0.3 * sin(2 * 0.4 * PI * elapsed)
	bicycle.global_position.y += 0.2 * sin(2 * 0.2 *  PI * elapsed)
	
func bicycle_clamp_on_screen():
	bicycle.global_position.x = clamp(bicycle.global_position.x, camera_bounds["left"], camera_bounds["right"])
	if bicycle.global_position.x <= camera_bounds["left"] or bicycle.global_position.x >= camera_bounds["right"]:
		bicycle.velocity.x = 0
		
	bicycle.global_position.y = clamp(bicycle.global_position.y, camera_bounds["top"], camera_bounds["bottom"])
	if bicycle.global_position.y <= camera_bounds["top"] or bicycle.global_position.y >= camera_bounds["bottom"]:
		bicycle.velocity.y = 0
		
func spawn_object(scene):
	var obj = scene.instance()
	obj.position.x = camera_bounds["right"] + 200
	var y_pos = rng.randi_range(camera_bounds["top"] + 200, camera_bounds["bottom"] - 200)
	obj.position.y = y_pos
	add_child(obj)
	obj.connect("collided", self, "_on_Object_collided")


func _on_ObjectSpawnerTimer_timeout():
	if rng.randf() < 0.5:
		spawn_object(obstacle_scene)
	else:
		spawn_object(collectable_scene)
	
func _on_Object_collided(obj, colliding_obj):
	if (colliding_obj is Bicycle or colliding_obj.captured) and not obj.captured:
		print("collided one")
		if (not obj.captured) and obj.is_in_group("collectable"):
			print("collided two")
			obj.collided = true
			bicycle.capture_object(obj)
		if obj.is_in_group("obstacle") and obj.collided == false:
			print("collided three")
			obj.collided = true
			bicycle.release_object()
	
	
