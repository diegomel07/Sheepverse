extends Area2D

var polygon: Polygon2D
var collision_polygon: CollisionPolygon2D
var drawing = false
var points = PackedVector2Array()
var body_selected: bool = false
var current_bodies = []
var target_position: Vector2
var move_speed: float = 200.0  # Velocidad de movimiento en píxeles por segundo
var can_make_something = false

# Dirección y fuerza del movimiento
var push_direction = Vector2(700, 0)  # Mover 100 píxeles a la derecha
var push_force = 500  # Fuerza de empuje (para cuerpos con física)

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
			if not drawing:
				drawing = true
				points = PackedVector2Array()
			points.append(get_local_mouse_position())
			update_polygon()
		else:
			if points.size() >= 3:
				drawing = false
				update_polygon()
				check_bodies_in_polygon()
			else:
				points = PackedVector2Array()
				update_polygon()
	elif event is InputEventMouseMotion and drawing:
		if points.size() > 0:
			points.append(get_local_mouse_position())
			update_polygon()

func update_polygon():
	polygon.polygon = points
	collision_polygon.polygon = points
	# Forzar la actualización de la forma de colisión
	collision_polygon.disabled = true
	collision_polygon.disabled = false

func check_bodies_in_polygon():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		print(body.name + " ya está dentro del área")

func _process(delta):
	queue_redraw()

func _physics_process(delta):
	if can_make_something:
		for body in current_bodies:
			move_towards_mouse(body)

func move_towards_mouse(body):
	# Obtiene la posición global del mouse
	var mouse_pos = get_global_mouse_position()
	
	# Calcula la dirección hacia el mouse
	var direction = (mouse_pos - body.global_position).normalized()
	
	# Define la velocidad de movimiento
	var speed = 200  # Ajusta este valor según lo necesites
	
	# Calcula la velocidad
	body.velocity = direction * speed
	
	# Mueve el personaje
	body.move_and_slide()
	

func _draw():
	if points.size() > 1:
		draw_polyline(points, Color.RED, 2.0)

func _on_body_entered(body):
	if body is CharacterBody2D and !drawing:
		body_selected = true
		current_bodies.push_back(body)
	

func _on_body_exited(body):
	pass
	#current_bodies.erase(body)
