extends Area2D

@onready var tile_map = %TileMap
@onready var collecting_animation = $Collecting_animation
@onready var player = %Player
@onready var speech_sound = preload("res://assets/sounds/meeeeeh.wav")
@onready var speech_sound2 = preload("res://assets/sounds/click.wav")


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
var stuck_timeout = 1.0  # Segundos antes de considerar que un cuerpo está atascado
var collect_timeout = 5.0 # Segundos que se tardan en recolectar
var body_stuck_time = {}
var can_change_target = true
var what_sheeps_doing: String = 'nothing'
var sheeps_can_collect = false
var tile_erase_layer: int
var tile_erase_position: Vector2
var collecting_type: String
var cont_sheeps_with_stamina: int


func _ready():
	polygon = Polygon2D.new()
	polygon.color = Color(0, 0, 0, 0.5)  # Azul semitransparente
	add_child(polygon)
	collision_polygon = CollisionPolygon2D.new()
	add_child(collision_polygon)


func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			can_make_something = true
			if can_change_target:
				target_position = get_global_mouse_position()
			global_mouse = get_local_mouse_position()
			if body_selected:
				check_tile()
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
	# Collecting
	if what_sheeps_doing == 'nothing' and sheeps_can_collect:
		collecting_animation.visible = true
		collecting_animation.global_position = target_position
		collecting_animation.get_node("AnimatedSprite2D").play('collecting')
		can_draw = false
		can_change_target = false
		can_make_something = false
		#print('Collecting')
		time_collecting += delta
		print(time_collecting)
		
		if time_collecting >= collect_timeout:
			collecting_animation.visible = false
			collecting_animation.get_node("AnimatedSprite2D").stop()
			tile_map.erase_cell(tile_erase_layer, tile_erase_position)
			can_draw = true
			can_change_target = true
			can_make_something = true
			sheeps_can_collect = false
			collect_timeout = 5
			
			# añadiendo la cantidad de objectos recolectados
			if collecting_type == 'rock':
				player.set_rocks(player.get_rocks()+4)
			elif collecting_type == 'wood':
				player.set_wood(player.get_wood()+4)
			elif collecting_type == 'grass':
				player.set_grass(player.get_grass()+4)
	
	# Moving
	if can_make_something:
		make_something(delta)
	if current_bodies.size() == 0:
		can_make_something = false
	queue_redraw()


func check_tile():
	cont_sheeps_with_stamina = 0
	# Obtiene la posición del clic en coordenadas globales
	var click_position = get_global_mouse_position()
	
	# Convierte la posición global a coordenadas de tile
	var tile_position = tile_map.local_to_map(tile_map.to_local(click_position))
	
	for i in tile_map.get_layers_count():
		# obtiene los datos del tile en esa posicion
		var tile_data = tile_map.get_cell_tile_data(i, tile_position)
		if !tile_data is TileData:
			continue
		# obtiene el tipo de tile
		var tile_type = tile_data.get_custom_data_by_layer_id(0)
		if tile_type == 'terrain':
			sheeps_can_collect = false
			what_sheeps_doing = 'walking'
		if tile_type == 'rock' or tile_type == 'wood' or tile_type == "grass":
			DialogueManager.start_dialog(["recolecten perras"], speech_sound)
			for body in current_bodies:
				if body.get_stamina() >= 0:
					cont_sheeps_with_stamina += 1
				body.set_stamina(body.get_stamina()-20)
				#print('La oveja ', body.name, ' tiene ', body.get_stamina(), ' de stamina')
			tile_erase_layer = i
			tile_erase_position = tile_position
			time_collecting = 0
			collect_timeout -= cont_sheeps_with_stamina
			if cont_sheeps_with_stamina > 0:
				collecting_type = tile_type
				sheeps_can_collect = true
		#print("Clic en tile en posición: ", tile_position, ' Tipo: ', tile_type)

var time_collecting = 0
func make_something(delta):
	# move towards the click
	if what_sheeps_doing == "walking":
		if !sheeps_can_collect:
			DialogueManager.start_dialog(["caminen perras"], speech_sound)
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
		body.velocity = Vector2.ZERO
		#print(body.name, ' ha llegado a su destino')
		current_bodies.erase(body)
		body_destinations.erase(body)  # Elimina el destino asignado
		if current_bodies.size() == 0:
			what_sheeps_doing = 'nothing'
	else:
		can_draw = false
		can_change_target = false
		body_selected = false
		#print('Distancia al destino: ', body.global_position.distance_to(destination))
		
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

var dash_length = 10  # Longitud de cada segmento de la línea punteada
var gap_length = 5    # Longitud del espacio entre segmentos

func _draw():
	if points.size() > 1:
		draw_polyline(points, Color(166, 146, 176), 2.0)
	#draw_circle(global_mouse, target_radius, Color(1,0,0, 0.5))
	

func _on_body_entered(body):
	if body is CharacterBody2D and body.name != "Player" and !drawing:
		if not current_bodies.has(body):
			current_bodies.push_back(body)
			body_selected = true

func _on_body_exited(body):
	pass
