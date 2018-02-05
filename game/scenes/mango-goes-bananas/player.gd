extends "res://game/player/player.gd"

signal started_working
signal stopped_working

var utils = preload("res://game/utils.gd")

onready var mango = get_parent().get_node("Mango")
onready var sofa_myrjam = get_parent().get_node("sofa-myrjam-location")
onready var sofa_stijn = get_parent().get_node("sofa-stijn-location")

var do_action
var cleaning = false
var drawing = false
var studying = false
var reachable_mischief


func _ready():
	._ready()
	set_process_input(true)
	do_action = player_name_str + "_do"


func _input(event):
	if event.is_action_released(do_action):
		if drawing:
			stop_drawing()
		elif studying:
			stop_studying()
		elif cleaning:
			stop_cleaning()
		elif is_mischief_nearby():
			clean()
		elif player_name == MYRJAM and is_sofa_myrjam_nearby():
			draw()
		elif player_name == STIJN and is_sofa_stijn_nearby():
			study()


func fixed_process(delta):
	if not is_busy():
		.fixed_process(delta)


func is_mischief_nearby():
	for mischief in get_tree().get_nodes_in_group("mischief"):
		if get_global_pos().distance_to(mischief.get_global_pos()) < 85:
			reachable_mischief = mischief
			return true
	reachable_mischief = null
	return false


func clean():
	assert reachable_mischief != null
	
	mango.interrupt()
	animations.play("cleaning profile start")
	cleaning = true
	reachable_mischief.clean()
	reachable_mischief.connect("cleaned", self, "cleaned")
	utils.do_once_after_animation(animations, animations, "play", ["cleaning profile middle"])


func stop_cleaning():
	cleaning = false
	reachable_mischief.stop_cleaning()
	animations.play("cleaning profile end")
	utils.do_once_after_animation(animations, self, "unbusy")


func cleaned():
	stop_cleaning()
	reachable_mischief.queue_free()


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
	set_layer_mask(0)
	set_collision_mask(0)
	emit_signal("started_working")
	utils.do_once_after_animation(animations, self, "keep_studying")


func keep_studying():
	animations.play("study middle")


func stop_studying():
	animations.play("study end")
	set_layer_mask(1)
	set_collision_mask(1)
	emit_signal("stopped_working")
	utils.do_once_after_animation(animations, self, "unbusy")


func is_busy():
	return drawing or studying or cleaning


func unbusy():
	drawing = false
	studying = false
	cleaning = false