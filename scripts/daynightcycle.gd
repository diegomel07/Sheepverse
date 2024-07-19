extends CanvasModulate


# 6 a 6 y que esas 6 horas duren 6 minutos 
# ciclo de 24 horas de 12 minutos 720 segundos INGAME_SPEED = 2

const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOUR = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY


signal time_tick(day:int, hour:int, minute:int)
signal a_mimir()


@export var gradient_texture:GradientTexture1D
@export var INGAME_SPEED = 2
@export var INITIAL_HOUR = 7:
	set(h):
		INITIAL_HOUR = h
		time = INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * INITIAL_HOUR


var time:float= 0.0
var past_minute:int= -1


func _ready() -> void:
	time = INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * INITIAL_HOUR


func _process(delta: float) -> void:
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * INGAME_SPEED
	
	var value = (sin(time - PI / 2.0) + 1.0) / 2.0
	self.color = gradient_texture.gradient.sample(value)
	
	_recalculate_time(delta)	

		
func _recalculate_time(delta: float) -> void:
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	
	var day = int(total_minutes / MINUTES_PER_DAY)
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	var hour = int(current_day_minutes / MINUTES_PER_HOUR)
	var minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	 # Comprobamos si son las 6 AM o 6 PM
	if hour == 18 and minute == 0:
		a_mimir.emit()
		# Saltamos 12 horas
		time += INGAME_TO_REAL_MINUTE_DURATION * MINUTES_PER_HOUR * 12
		# Recalculamos el tiempo después del salto
		total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
		day = int(total_minutes / MINUTES_PER_DAY)
		current_day_minutes = total_minutes % MINUTES_PER_DAY
		hour = int(current_day_minutes / MINUTES_PER_HOUR)
		minute = int(current_day_minutes % MINUTES_PER_HOUR)
	
	if day == 3:
		print('perdiste')
	
	if past_minute != minute:
		past_minute = minute
		time_tick.emit(day, hour, minute)
		print("Dia: ",day ," hora: ",hour,  " minuto: ", minute)
