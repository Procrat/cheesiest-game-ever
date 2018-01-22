extends KinematicBody2D

enum PlayerName {MYRJAM, STIJN}

export(int, "Myrjam", "Stijn") var player_name
export(float) var walk_speed

var left_action
var right_action
var up_action
var down_action

onready var animations = get_node("animations")

var last_action = "idle"
var last_direction = "front"
var last_clothing = "normal"
var last_flipped = false

func _ready():
	set_fixed_process(true)
	var player_name_str = "myrjam" if player_name == MYRJAM else "stijn"
	left_action = player_name_str + "_left"
	right_action = player_name_str + "_right"
	up_action = player_name_str + "_up"
	down_action = player_name_str + "_down"

func _fixed_process(delta):
	var direction = Vector2()
	var direction_name = null
	var flipped = false
	if Input.is_action_pressed(up_action):
		direction.y -= 1
		direction_name = "back"
	if Input.is_action_pressed(down_action):
		direction.y += 1
		direction_name = "front"
	if Input.is_action_pressed(left_action):
		direction.x -= 1
		direction_name = "profile"
		flipped = true
	if Input.is_action_pressed(right_action):
		direction.x += 1
		direction_name = "profile"
	
	if direction_name == null:
		# No input: idle
		set_animation("idle", last_direction, last_clothing, last_flipped)
	else:
		# Input: Move & animate
		set_animation("walk", direction_name, last_clothing, flipped)
		move_in_direction(direction, delta)

func move_in_direction(direction, delta):
	var motion = move(direction * walk_speed * delta)
	
	if (is_colliding()):
		var normal = get_collision_normal()
		motion = normal.slide(motion)
		move(motion)

func set_animation(action, direction, clothing, flipped):
	animations.play(action + " " + direction + " " + clothing)
	animations.set_flip_h(flipped)
	
	last_action = action
	last_direction = direction
	last_clothing = clothing
	last_flipped = flipped
