extends KinematicBody2D

enum PlayerName {MYRJAM, STIJN}

export(int, "Myrjam", "Stijn") var player_name
export(float) var walk_speed

var left_action
var right_action
var up_action
var down_action

func _ready():
	set_fixed_process(true)
	var player_name_str = "myrjam" if player_name == MYRJAM else "stijn"
	left_action = player_name_str + "_left"
	right_action = player_name_str + "_right"
	up_action = player_name_str + "_up"
	down_action = player_name_str + "_down"

func _fixed_process(delta):
	var pos = get_pos()
	if Input.is_action_pressed(left_action):
		pos.x -= walk_speed * delta
	elif Input.is_action_pressed(right_action):
		pos.x += walk_speed * delta
	if Input.is_action_pressed(up_action):
		pos.y -= walk_speed * delta
	elif Input.is_action_pressed(down_action):
		pos.y += walk_speed * delta
	move_to(pos)