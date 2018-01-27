extends "res://game/player/player.gd"

var Pickable = preload("res://game/scenes/lets-get-intentse/pickable.gd")

export(float) var min_distance_to_significant_other_in_dangerous_areas

var intialised = false
var original_location
var pick_up_action
var significant_other
var in_dangerous_area = false
onready var grabbing_area = get_node("grabbing-area")
var held_item = null


func _ready():
	._ready()
	set_process_input(true)
	
	if not intialised:
		original_location = get_pos()
		pick_up_action = player_name_str + "_pick_up"
		significant_other = get_parent().find_node("Stijn" if player_name == MYRJAM else "Myrjam")
		get_tree().call_group(0, "dangerous-area", "connect", "body_enter", self, "someone_entered_dangerous_area")
		get_tree().call_group(0, "dangerous-area", "connect", "body_exit", self, "someone_exited_dangerous_area")
		intialised = true


func _input(event):
	if event.is_action_released(pick_up_action):
		if carrying_something():
			drop()
		else:
			try_to_pick_up()


func fixed_process(delta):
	if in_dangerous_area and not close_to(significant_other):
		scream()
	else:
		.fixed_process(delta)


func someone_entered_dangerous_area(someone):
	if someone == self:
		print(player_name_str, " entered")
		in_dangerous_area = true


func someone_exited_dangerous_area(someone):
	if someone == self:
		print(player_name_str, " exited")
		in_dangerous_area = false


func close_to(player):
	return get_pos().distance_to(player.get_pos()) < min_distance_to_significant_other_in_dangerous_areas


func scream():
	print("AARGH, HELP")


func carrying_something():
	return held_item != null


func try_to_pick_up():
	assert not carrying_something()
	
	var grabbables = grabbing_area.get_overlapping_areas()
	var closest_pickable_item = null
	var shortest_distance_sq = null
	for item in grabbables:
		if item extends Pickable:
			var distance_sq = get_pos().distance_squared_to(item.get_pos())
			if shortest_distance_sq == null or distance_sq < shortest_distance_sq:
				closest_pickable_item = item
				shortest_distance_sq = distance_sq
	if closest_pickable_item != null:
		if closest_pickable_item.be_picked_up_by(self):
			held_item = closest_pickable_item


func drop():
	assert carrying_something()
	
	if held_item.be_dropped():
		held_item = null


func respawn():
	set_pos(original_location)
