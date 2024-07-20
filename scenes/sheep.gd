extends CharacterBody2D

@onready var animated_sprite_2d = $AnimatedSprite2D
var direction: Vector2
var stamina: int = 3
@onready var progress_bar = $ProgressBar

func _ready():
	progress_bar.value = stamina

func _process(delta):
	progress_bar.value = stamina
	if stamina <= 0:
		$zzz.visible = true
		$zzz.play("zzz")
	else:
		$zzz.visible = false
		$zzz.stop()

func _physics_process(delta):
	
	direction = velocity.normalized()
	
	# flipping the character
	if direction.x != 0:
		animated_sprite_2d.flip_h = (direction.x >= -1 and direction.x < 0)
	
	# idle
	if direction == Vector2.ZERO:
		animated_sprite_2d.play("idle")
		
	# moving up
	elif direction.y < 0:
		animated_sprite_2d.play("up")
	else:
		animated_sprite_2d.play("walk")

func set_stamina(new_stamina):
	$ProgressBar.value = stamina
	stamina = new_stamina

func get_stamina():
	return stamina
