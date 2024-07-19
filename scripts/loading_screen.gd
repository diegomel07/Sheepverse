extends Control
var progress = []
var scene 
var status = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	scene = "res://Scenes/World.tscn"
	ResourceLoader.load_threaded_request(scene)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	status = ResourceLoader.load_threaded_get_status(scene, progress)
	print(progress)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		var newScene = ResourceLoader.load_threaded_get(scene)
		get_tree().change_scene_to_packed(newScene)
