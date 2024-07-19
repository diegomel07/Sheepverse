extends CanvasLayer

@onready var inventory = $inventory

func _ready():
	inventory.close()

func _input(event):
	if event.is_action_pressed("inventory"):
		if inventory.is_open:
			inventory.close()
		else:
			inventory.open()
	
