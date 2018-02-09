extends "res://game/player/player.gd"

signal started_working
signal stopped_working

var utils = preload("res://game/utils.gd")
var Hint = preload("res://game/ui/text-fx player.tscn")

onready var mango = get_parent().get_node("Mango")
onready var sofa_myrjam = get_parent().get_node("sofa-myrjam-location")
onready var sofa_stijn = get_parent().get_node("sofa-stijn-location")

var do_action
var cleaning = false
var drawing = false
var studying = false
var reachable_mischief
var hint


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
	spawn_relevant_hints()
	if not is_busy():
		.fixed_process(delta)


func spawn_relevant_hints():
	if studying:
		spawn_hint("stop studying")
	elif drawing:
		spawn_hint("stop drawing")
	elif is_mischief_nearby() and not cleaning:
		spawn_hint("clean up this mess")
	elif player_name == STIJN and is_sofa_stijn_nearby() and not studying:
		spawn_hint("study")
	elif player_name == MYRJAM and is_sofa_myrjam_nearby() and not drawing:
		spawn_hint("draw")


func spawn_hint(hint_action):
	if hint != null:
		return

	hint = Hint.instance()
	hint.get_node("label").set_text("Press " + do_key() + " to " + hint_action)
	add_child(hint)
	utils.do_once_after_animation(hint.get_node("player"), self, "drop_hint")


func drop_hint():
	hint.queue_free()
	hint = null


func do_key():
	for event in InputMap.get_action_list(do_action):
		if event.type == InputEvent.KEY:
			return OS.get_scancode_string(event.scancode)
	return "the right key"

func is_mischief_nearby():
	for mischief in get_tree().get_nodes_in_group("mischief"):
		var mischief_area = mischief.get_parent()
		if mischief_area.overlaps_body(self):
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
	return sofa_myrjam.overlaps_body(self)


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
	return sofa_stijn.overlaps_body(self)


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