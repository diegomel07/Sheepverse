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
var target_radius: float = 80  # Radio del círculo objetivo
var global_mouse = Vector2.ZERO
var body_destinations = {}
var stuck_timeout = 3.0  # Segundos antes de considerar que un cuerpo está atascado
var body_stuck_time = {}
var can_change_target = true

func _ready():
	polygon = Polygon2D.new()
	polygon.color = Color(0, 0, 1, 0.5)  # Azul semitransparente
	add_child(polygon)
	collision_polygon = CollisionPolygon2D.new()
	add_child(collision_polygon)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if body_selected:
					can_make_something = true
					if can_change_target:
						target_position = get_global_mouse_position()
					global_mouse = get_local_mouse_position()
					print("Target position set to: ", target_position)
			if not can_draw:
				can_draw = true
				can_change_target = true
				points = PackedVector2Array()
			points.append(get_local_mouse_position())
			update_polygon()
		else:
			if points.size() >= 3:
				can_draw = false
				update_polygon()
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
	if current_bodies.size() == 0:
		can_make_something = false
	queue_redraw()

func _physics_process(delta):
	if can_make_something:
		for body in current_bodies:
			move_towards_random_point(body, delta)
	
		

func assign_destination(body):
	# Si el cuerpo ya tiene un destino asignado, lo devolvemos
	if body in body_destinations:
		return body_destinations[body]
	
	# Genera un punto aleatorio dentro del círculo
	var random_angle = randf_range(0, TAU)  # Ángulo aleatorio en radianes
	var random_distance = randf_range(0, target_radius)
	var random_point = target_position + Vector2(cos(random_angle), sin(random_angle)) * random_distance
	
	# Almacena el punto de destino para este cuerpo
	body_destinations[body] = random_point
	
	return random_point

func move_towards_random_point(body, delta):
	# Obtiene el punto de destino asignado para este cuerpo
	var destination = assign_destination(body)
	var previous_position = body.global_position
	
	# Calcula la dirección hacia el punto asignado
	var direction = (destination - body.global_position).normalized()
	
	# Calcula la velocidad
	var velocity = direction * move_speed
	
	# Mueve el cuerpo usando move_and_slide
	body.velocity = velocity
	body.move_and_slide()
	
	# Verifica si el cuerpo ha llegado al punto asignado
	if body.global_position.distance_to(destination) < 30:  # Ajusta este valor según sea necesario
		print(body.name, ' ha llegado a su destino')
		current_bodies.erase(body)
		body_destinations.erase(body)  # Elimina el destino asignado
	else:
		can_draw = false
		can_change_target = false
		print('Distancia al destino: ', body.global_position.distance_to(destination))
		
	# Verifica si el cuerpo se ha movido
	if body.global_position.distance_to(previous_position) < 1:  # Ajusta este valor según sea necesario
		if body not in body_stuck_time:
			body_stuck_time[body] = 0
		body_stuck_time[body] += delta
		if body_stuck_time[body] > stuck_timeout:
			unstuck_body(body)
	else:
		body_stuck_time[body] = 0

func unstuck_body(body):
	print(body.name, " está atascado. Reubicando...")
	# Reasigna un nuevo destino
	body_destinations.erase(body)
	var new_destination = assign_destination(body)
	# Opcionalmente, mueve el cuerpo a una nueva posición inicial
	body.global_position = target_position + Vector2(randf_range(-target_radius, target_radius), randf_range(-target_radius, target_radius))
	body_stuck_time[body] = 0

func _draw():
	if points.size() > 1:
		draw_polyline(points, Color.RED, 2.0)
	draw_circle(global_mouse, target_radius, Color(1,0,0, 0.5))

func _on_body_entered(body):
	if body is CharacterBody2D and !drawing:
		if not current_bodies.has(body):
			current_bodies.push_back(body)
			body_selected = true

func _on_body_exited(body):
	pass
