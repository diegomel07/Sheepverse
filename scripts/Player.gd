extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D

var wood = 0
var rocks = 0
var grass = 0

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


func set_rocks(new_rocks):
	rocks = new_rocks
	print('Rocas ', rocks)
	
func get_rocks():
	return rocks
	
func set_wood(new_wood):
	wood = new_wood
	print('Madera', wood)
	


func get_wood():
	return wood
	
func set_grass(new_grass):
	grass = new_grass
	print('Pasto', grass)

func get_grass():
	return grass
