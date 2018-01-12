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
	var direction = Vector2()
	if Input.is_action_pressed(left_action):
		direction.x -= 1
	if Input.is_action_pressed(right_action):
		direction.x += 1
	if Input.is_action_pressed(up_action):
		direction.y -= 1
	if Input.is_action_pressed(down_action):
		direction.y += 1
	
	var motion = move(direction * walk_speed * delta)
	
	if (is_colliding()):
		var normal = get_collision_normal()
		motion = normal.slide(motion)
		move(motion)