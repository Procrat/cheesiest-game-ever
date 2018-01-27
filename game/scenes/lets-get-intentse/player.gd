extends "res://game/player/player.gd"


var Pickable = preload("res://game/scenes/lets-get-intentse/pickable.gd")

var original_location
var pick_up_action
onready var grabbing_area = find_node("grabbing-area")

var held_item = null


func _ready():
	._ready()
	set_process_input(true)
	if original_location == null:
		original_location = get_pos()
	pick_up_action = player_name_str + "_pick_up"


func _input(event):
	if event.is_action_released(pick_up_action):
		if carrying_something():
			drop()
		else:
			try_to_pick_up()


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
