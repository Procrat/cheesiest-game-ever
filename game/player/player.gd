extends KinematicBody2D

enum PlayerName {MYRJAM, STIJN}

export(int, "Myrjam", "Stijn") var player_name
export(float) var walk_speed
export(String, "normal", "hiking") var clothing = "normal"


class Direction extends Node:
	var translation
	var name
	var animation_flipped
	
	func _init(translation, name, animation_flipped):
		self.translation = translation
		self.name = name
		self.animation_flipped = animation_flipped


var player_name_str
var left_action
var right_action
var up_action
var down_action

onready var animations = get_node("animations")

var last_action = "idle"
var last_direction = "front"
var last_flipped = false


func _ready():
	set_fixed_process(true)
	player_name_str = "myrjam" if player_name == MYRJAM else "stijn"
	left_action = player_name_str + "_left"
	right_action = player_name_str + "_right"
	up_action = player_name_str + "_up"
	down_action = player_name_str + "_down"


func _fixed_process(delta):
	fixed_process(delta)


func fixed_process(delta):
	var direction = handle_input()
	
	if direction.name == null:
		# No input: idle
		set_animation("idle", last_direction, last_flipped)
	else:
		# Input: Move & animate
		set_animation("walk", direction.name, direction.animation_flipped)
		move_in_direction(direction.translation, delta)


func handle_input():
	var translation = Vector2()
	var direction_name = null
	var flipped = false
	
	if Input.is_action_pressed(up_action):
		translation.y -= 1
		direction_name = "back"
	if Input.is_action_pressed(down_action):
		translation.y += 1
		direction_name = "front"
	if Input.is_action_pressed(left_action):
		translation.x -= 1
		direction_name = "profile"
		flipped = true
	if Input.is_action_pressed(right_action):
		translation.x += 1
		direction_name = "profile"
	
	return Direction.new(translation, direction_name, flipped)


func move_in_direction(direction, delta):
	var motion = move(direction * walk_speed * delta)
	
	if (is_colliding()):
		var normal = get_collision_normal()
		motion = normal.slide(motion)
		move(motion)


func set_animation(action, direction, flipped):
	animations.play(action + " " + direction + " " + clothing)
	animations.set_flip_h(flipped)
	
	last_action = action
	last_direction = direction
	last_flipped = flipped
