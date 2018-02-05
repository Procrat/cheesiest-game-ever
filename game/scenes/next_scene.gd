extends Node

export(String, FILE, "*.tscn") var next_scene
export(int) var automatically_after_seconds = -1

var utils = preload("res://game/utils.gd")


func _ready():
	set_process_input(true)
	if automatically_after_seconds > 0:
		utils.do_once_after(automatically_after_seconds, self, self, "go_to_next_scene")


func _input(event):
	if event.is_action_pressed("ui_accept"):
		go_to_next_scene()
	get_tree().set_input_as_handled()


func go_to_next_scene():
	get_tree().change_scene(next_scene)
