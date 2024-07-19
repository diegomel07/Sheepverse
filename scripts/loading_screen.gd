extends Control
var progress = []
var scene 
var status = 0
var cinematicsCountdown = 2
var cinematics = []
#Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(true)
	scene = "res://Scenes/World.tscn"
	ResourceLoader.load_threaded_request(scene)
	pass # Replace with function body.


#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	status = ResourceLoader.load_threaded_get_status(scene, progress)


func _input(event):
	if event.is_pressed() and not event is InputEventMouseButton:
		print(cinematicsCountdown)
		if cinematicsCountdown < 8:
			changeCinematic()
			return
		if status == ResourceLoader.THREAD_LOAD_LOADED and cinematicsCountdown == 8:
			var newScene = ResourceLoader.load_threaded_get(scene)
			get_tree().change_scene_to_packed(newScene)
func changeCinematic():
	var nameCinematic = "Cinematica" + str(cinematicsCountdown)
	var newCinematic = get_node(nameCinematic)
	newCinematic.visible = true
	cinematicsCountdown +=1
