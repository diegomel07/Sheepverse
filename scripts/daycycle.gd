extends HSlider


func _on_canvas_modulate_time_tick(day, hour, minute):
	value = ((hour * 60 ) + minute) 
