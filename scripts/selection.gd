extends Area2D

var polygon: Polygon2D
var collision_polygon: CollisionPolygon2D
var drawing = false
var can_draw = false
var points = PackedVector2Array()
var body_selected: bool = false
var current_bodies = []
var target_position: Vector2
var move_speed: float = 200.0  # Velocidad de movimiento en píxeles por segundo
var can_make_something = false
var target_radius: float = 50  # Radio del círculo objetivo

func _ready():
	polygon = Polygon2D.new()
	polygon.color = Color(0, 0, 1, 0.5)  # Azul semitransparente
	add_child(polygon)
	collision_polygon = CollisionPolygon2D.new()
	add_child(collision_polygon)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not can_draw:
				if body_selected:
					can_make_something = true
					target_position = get_global_mouse_position()
					
					print("Target position set to: ", target_position)
				can_draw = true
				points = PackedVector2Array()
			points.append(get_local_mouse_position())
			update_polygon()
		else:
			if points.size() >= 3:
				can_draw = false
				update_polygon()
				#check_bodies_in_polygon()
			else:
				points = PackedVector2Array()
				update_polygon()
	elif event is InputEventMouseMotion and can_draw:
		drawing = true
		if points.size() > 0:
			points.append(get_local_mouse_position())
			update_polygon()
		if event.is_released():
			drawing = false

func update_polygon():
	polygon.polygon = points
	collision_polygon.polygon = points
	# Forzar la actualización de la forma de colisión
	collision_polygon.disabled = true
	collision_polygon.disabled = false


func _process(delta):
	print(current_bodies)
	if current_bodies.size() == 0:
		can_make_something = false
	queue_redraw()

func _physics_process(delta):
	if can_make_something:
		print('aun tamos')
		for body in current_bodies:
			move_towards_random_point(body, delta)
	else:
		print('no tamos')
		

func move_towards_random_point(body, delta):
	# Genera un punto aleatorio dentro del círculo
	var random_angle = randf_range(0, TAU)  # Ángulo aleatorio en radianes
	var random_distance = randf_range(0, target_radius)
	var random_point = target_position + Vector2(cos(random_angle), sin(random_angle)) * random_distance
	
	# Calcula la dirección hacia el punto aleatorio
	var direction = (random_point - body.global_position).normalized()
	
	# Calcula la velocidad
	var velocity = direction * move_speed * delta
	
	# Mueve el cuerpo
	body.global_position += velocity
	
	# Aplica el movimiento y deslizamiento
	body.move_and_slide()
	
	# Verifica si el cuerpo ha llegado al punto aleatorio
	if body.global_position.distance_to(random_point) < 20:  # Ajusta este valor según sea necesario
		current_bodies.erase(body)


func _draw():
	if points.size() > 1:
		draw_polyline(points, Color.RED, 2.0)

func _on_body_entered(body):
	if body is CharacterBody2D and !drawing:
		if not current_bodies.has(body):
			current_bodies.push_back(body)
			body_selected = true

func _on_body_exited(body):
	pass
