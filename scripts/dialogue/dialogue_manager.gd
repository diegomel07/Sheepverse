extends Node

@onready var text_box_scene = preload("res://scenes/text_box.tscn")

var dialog_lines: Array[String] = []
var current_line_index = 0

var text_box
var text_box_position: Vector2

var sfx: AudioStream

var is_dialog_active = false
var can_advance_line = false
var player_global_position: Vector2

func _process(delta):
	if is_dialog_active:
		text_box.global_position = Vector2(player_global_position.x, player_global_position.y - 70)

func start_dialog(lines: Array[String], speech_sfx: AudioStream):
	if is_dialog_active:
		return
	
	dialog_lines = lines
	#text_box_position = player_global_position
	sfx = speech_sfx
	_show_text_box()
	
	is_dialog_active = true
	
func _show_text_box():
	text_box = text_box_scene.instantiate()
	text_box.finished_displaying.connect(_on_text_finished_displaying)
	get_tree().root.add_child(text_box)
	#ext_box.global_position = text_box_position
	text_box.display_text(dialog_lines[current_line_index], sfx)
	can_advance_line = false

func _on_text_finished_displaying():
	can_advance_line = true
	
func _unhandled_input(event): 
	if ((event.is_action_pressed("advance_dialog") or dialog_lines.size() == 1) and
	is_dialog_active and
	can_advance_line 
	):
		if dialog_lines.size() == 1:
			pass #play animation
		text_box.queue_free()
		
		current_line_index += 1
		if current_line_index >= dialog_lines.size():
			is_dialog_active = false
			current_line_index = 0
			return
		_show_text_box()
