extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
@export var inventory: Inventory

var wood = 0
var rocks = 0
var grass = 0

var rock_item: InventoryItem = preload("res://inventory/items/rock.tres")
var wood_item: InventoryItem = preload("res://inventory/items/wood.tres")
var grass_item: InventoryItem = preload("res://inventory/items/grass.tres")

const SPEED = 100.0

func _physics_process(delta):
	
	var direction = Vector2.ZERO
	direction.x = Input.get_axis("left", "right")
	direction.y = Input.get_axis("up", "down")
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()
		velocity = direction * SPEED
		
		# Manejo de animaciones
		if direction.x:
			animated_sprite_2d.play("walk")
			animated_sprite_2d.flip_h = (direction.x < 0)
		else:
			if direction.y > 0:
				animated_sprite_2d.play("down")
			else:
				animated_sprite_2d.play("up")
	else:
		velocity = velocity.move_toward(Vector2.ZERO, SPEED)
		animated_sprite_2d.play("idle")
	
	move_and_slide()
	DialogueManager.player_global_position = global_position


func set_rocks(new_rocks):
	rocks = new_rocks
	if rock_item not in inventory.slots:
		inventory.insert(rock_item)
	#print('Rocas ', rocks)
	
func get_rocks():
	return rocks
	
func set_wood(new_wood):
	wood = new_wood
	#print('Madera', wood)
	if wood_item not in inventory.slots:
		inventory.insert(wood_item)
	

func get_wood():
	return wood
	
func set_grass(new_grass):
	grass = new_grass
	#print('Pasto', grass)
	if grass_item not in inventory.slots:
		inventory.insert(grass_item)

func get_grass():
	return grass
