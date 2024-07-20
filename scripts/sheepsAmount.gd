extends Label

@onready var sheeps = %sheeps.get_children()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sheeps = %sheeps.get_children()
	text = 'Ovejas: ' + str(sheeps.size())
