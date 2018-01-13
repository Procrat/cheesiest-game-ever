extends Node

export(String, FILE, "*.tscn") var next_scene

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene(next_scene)
	get_tree().set_input_as_handled()
