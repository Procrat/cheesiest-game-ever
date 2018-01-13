extends Node

export(String, FILE, "*.tscn") var next_scene

func _ready():
	set_process(true)

func _process(delta):
	if Input.is_action_pressed("ui_accept"):
		get_tree().change_scene(next_scene)
