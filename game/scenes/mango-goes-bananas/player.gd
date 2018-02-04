extends "res://game/player/player.gd"

var utils = preload("res://game/utils.gd")

onready var sofa = get_parent().get_node("sofa-location")

var do_action
var drawing = false


func _ready():
	._ready()
	set_process_input(true)
	do_action = player_name_str + "_do"


func _input(event):
	if event.is_action_released(do_action):
		if player_name == MYRJAM and is_sofa_nearby():
			if not drawing:
				draw()
			else:
				stop_drawing()


func fixed_process(delta):
	if not is_busy():
		.fixed_process(delta)


func is_sofa_nearby():
	print(get_global_pos().distance_to(sofa.get_global_pos()))
	return get_global_pos().distance_to(sofa.get_global_pos()) < 100


func draw():
	print("start drawing")
	animations.play("draw start")
	drawing = true
	utils.do_once_after_animation(animations, self, "keep_drawing")


func keep_drawing():
	animations.play("draw middle")


func stop_drawing():
	animations.play("draw end")
	utils.do_once_after_animation(animations, self, "unbusy")


func is_busy():
	return drawing


func unbusy():
	drawing = false