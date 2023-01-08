extends Node

onready var camera_pos = $Camera2D.global_position
onready var camera_bounds = {
	"top": camera_pos.y - Game.size.y / 2,
	"bottom": camera_pos.y + Game.size.y / 2,
	"left": camera_pos.x - Game.size.x / 2,
	"right": camera_pos.x + Game.size.x / 2,
}
onready var bicycle = $Bicycle

# `pre_start()` is called when a scene is loaded.
# Use this function to receive params from `Game.change_scene(params)`.
func pre_start(params):
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
	bicycle.global_position.x = clamp(bicycle.global_position.x, camera_bounds["left"], camera_bounds["right"])
	if bicycle.global_position.x <= camera_bounds["left"] or bicycle.global_position.x >= camera_bounds["right"]:
		bicycle.velocity.x = 0
		
	bicycle.global_position.y = clamp(bicycle.global_position.y, camera_bounds["top"], camera_bounds["bottom"])
	if bicycle.global_position.y <= camera_bounds["top"] or bicycle.global_position.y >= camera_bounds["bottom"]:
		bicycle.velocity.y = 0
