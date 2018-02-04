extends "res://game/player/player.gd"

signal started_working
signal stopped_working

var utils = preload("res://game/utils.gd")

onready var sofa_myrjam = get_parent().get_node("sofa-myrjam-location")
onready var sofa_stijn = get_parent().get_node("sofa-stijn-location")

var do_action
var drawing = false
var studying = false


func _ready():
	._ready()
	set_process_input(true)
	do_action = player_name_str + "_do"


func _input(event):
	if event.is_action_released(do_action):
		if player_name == MYRJAM:
			if is_sofa_myrjam_nearby():
				if not drawing:
					draw()
				else:
					stop_drawing()
		elif player_name == STIJN:
			if is_sofa_stijn_nearby():
				if not studying:
					study()
				else:
					stop_studying()


func fixed_process(delta):
	if not is_busy():
		.fixed_process(delta)


func is_sofa_myrjam_nearby():
	return get_global_pos().distance_to(sofa_myrjam.get_global_pos()) < 30


func draw():
	animations.set_flip_h(false)
	animations.play("draw start")
	set_global_pos(sofa_myrjam.get_global_pos())
	drawing = true
	emit_signal("started_working")
	utils.do_once_after_animation(animations, self, "keep_drawing")


func keep_drawing():
	animations.play("draw middle")


func stop_drawing():
	animations.play("draw end")
	emit_signal("stopped_working")
	utils.do_once_after_animation(animations, self, "unbusy")


func is_sofa_stijn_nearby():
	return get_global_pos().distance_to(sofa_stijn.get_global_pos()) < 30


func study():
	animations.set_flip_h(false)
	animations.play("study start")
	set_global_pos(sofa_stijn.get_global_pos())
	studying = true
	emit_signal("started_working")
	utils.do_once_after_animation(animations, self, "keep_studying")


func keep_studying():
	animations.play("study middle")


func stop_studying():
	animations.play("study end")
	emit_signal("stopped_working")
	utils.do_once_after_animation(animations, self, "unbusy")


func is_busy():
	return drawing or studying


func unbusy():
	drawing = false
	studying = false