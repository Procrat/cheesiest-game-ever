extends Node2D

const Fade = preload("res://game/player/fade.tscn")
const utils = preload("res://game/utils.gd")

onready var objects = get_node("objects").get_children()
onready var inventory = get_node("inventory/VBoxContainer").get_children()
onready var i_give_up_button = get_node("i-give-up")
onready var end_screen = get_node("end-screen")

var found = []


func _ready():
	for object_idx in range(objects.size()):
		found.append(false)
		var object = objects[object_idx]
		object.connect("input_event", self, "mouse_on_object_event", [object_idx])
	
	i_give_up_button.connect("pressed", self, "give_up")


func mouse_on_object_event(_viewport, event, _shape_idx, object_idx):
	if event.is_pressed() and not found[object_idx]:
		found[object_idx] = true
		
		var pos = event.pos + Vector2(-15, -35)
		
		var fade_out = Fade.instance()
		objects[object_idx].get_node("sprite").add_child(fade_out)
		fade_out.set_pos(pos)
		fade_out.get_node("player").play("fade out")
		
		var fade_in = Fade.instance()
		inventory[object_idx].get_node("sprite").add_child(fade_in)
		fade_in.set_pos(pos)
		fade_in.get_node("player").play("fade in")
		
		inventory[object_idx].get_node("text").add_color_override("font_color", Color("f92b66"))
		
		if are_all_objects_found():
			utils.do_once_after_animation(fade_in.get_node("player"), self, "win")


func are_all_objects_found():
	for found_object in found:
		if not found_object:
			return false
	return true


func win():
	end_screen.show(true, found)


func give_up():
	end_screen.show(false, found)
