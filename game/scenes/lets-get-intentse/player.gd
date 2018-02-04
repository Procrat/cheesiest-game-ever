extends "res://game/player/player.gd"

var utils = preload("res://game/utils.gd")
var Pickable = preload("res://game/scenes/lets-get-intentse/pickable.gd")
enum JumpDirection {UP, DOWN}
enum JumpSize {BIG, SMALL}

export(float) var min_distance_to_significant_other_in_dangerous_areas
export(float) var max_distance_to_climables = 50
export(float) var upward_jumping_time = 0.5

var intialised = false
var original_location
var pick_up_action
var significant_other
var in_dangerous_area = false
onready var grabbing_area = get_node("grabbing-area")
var held_item = null
var picking_up = false
var drowning = false
var beckoning = false
var jumping = false
var on_tree = false
var over_tree = false
var jump_size
var upward_jump_countdown
var tree
var animation_duration
var jump_off_translation


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
		if not picking_up and not jumping and not beckoning:
			if carrying_something():
				drop()
			elif not over_tree and is_tree_nearby():
				climb_over_tree()
			else:
				try_to_pick_up()


func fixed_process(delta):
	if drowning or (in_dangerous_area and not significant_other.in_dangerous_area and not close_to(significant_other)):
		panic()
	elif jumping:
		continue_jumping(delta)
	elif beckoning and handle_input().translation.length() <= 0:
		if animations.get_animation() != "beckoning":
			animations.play("beckoning")
	elif not picking_up and not (player_name == STIJN and on_tree):
		.fixed_process(delta)


func someone_entered_dangerous_area(someone):
	if someone == self:
		in_dangerous_area = true


func someone_exited_dangerous_area(someone):
	if someone == self:
		in_dangerous_area = false


func close_to(player):
	return get_pos().distance_to(player.get_pos()) < min_distance_to_significant_other_in_dangerous_areas


func panic():
	animations.play("panic")


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
			really_pick_something_up(closest_pickable_item)


func really_pick_something_up(item):
	held_item = item
	set_global_pos(item.get_global_pos())
	var item_name = "rock" if item.get_name().begins_with("rock") else "stick"
	animations.play("pick up " + item_name)
	picking_up = true
	utils.do_once_after_animation(animations, self, "done_picking_up")


func done_picking_up():
	picking_up = false


func drop():
	assert carrying_something()
	
	if held_item.be_dropped():
		held_item = null


func drown():
	drowning = true
	panic()
	animations.connect("finished", self, "respawn")


func respawn():
	drowning = false
	animations.disconnect("finished", self, "respawn")
	set_pos(original_location)


func is_tree_nearby():
	var grabbables = grabbing_area.get_overlapping_bodies()
	for grabbable in grabbables:
		if grabbable.is_in_group("climbable") and grabbable.get_pos().distance_to(get_pos()) < max_distance_to_climables:
			tree = grabbable
			return true
	tree = null
	return false


func climb_over_tree():
	assert not carrying_something()
	
	if player_name == STIJN and not significant_other.over_tree and on_tree:
		return
	
	if player_name == MYRJAM and not on_tree and not over_tree:
		set_global_pos(tree.get_node("before/myrjam").get_global_pos())
	
	jumping = true
	upward_jump_countdown = upward_jumping_time
	jump_size = BIG if player_name == STIJN or significant_other.on_tree else SMALL
	
	var animation = "jump with help" if jump_size == BIG and not on_tree else "jump"
	animations.play(animation)
	var sprites = animations.get_sprite_frames()
	animation_duration = sprites.get_frame_count(animation) / sprites.get_animation_speed(animation)
	animations.connect("finished", self, "stop_jumping")


func continue_jumping(delta):
	var translation
	if upward_jump_countdown > 0:
		if jump_size == BIG:
			translation = Vector2(0, -20 * delta)
		else:
			translation = Vector2(0, -20 * delta)
		upward_jump_countdown -= delta
	else:
		if jump_size == BIG:
			if upward_jump_countdown + delta > 0:
				upward_jump_countdown -= delta
				var where_relative_to_tree = "after" if on_tree else "on-top"
				var goal = tree.get_node(where_relative_to_tree).get_node(player_name_str).get_global_pos()
				var diff = goal - get_global_pos()
				var speed = diff.length() / (animation_duration - upward_jumping_time)
				jump_off_translation = diff.clamped(speed * delta)
			translation = jump_off_translation
		else:
			translation = Vector2(0, 40 * delta)
	translate(translation)


func stop_jumping():
	jumping = false
	animations.disconnect("finished", self, "stop_jumping")
	
	var was_on_tree = on_tree
	on_tree = tree.get_node("on-tree").overlaps_body(self)
	if was_on_tree and not on_tree:
		over_tree = true
	
	if player_name == STIJN and on_tree:
		animations.play("holding out hand")
		animations.flip_h = false


func beckon():
	beckoning = true
	animations.play("beckoning")
	animations.flip_h = true


func stop_beckoning():
	beckoning = false
