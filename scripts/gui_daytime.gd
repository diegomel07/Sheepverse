extends Label

func _on_canvas_modulate_time_tick(day, hour, minute):
	text = "Son las " + str(hour) + " : " + str(minute) + ' del dia ' + str(day) 
