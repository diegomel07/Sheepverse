extends Control

signal opened
signal closed

var is_open: bool = false

func open():
	visible = true
	is_open = true
	opened.emit()

func close():
	visible = false
	is_open = false
	closed.emit()
