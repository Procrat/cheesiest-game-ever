extends KinematicBody2D

enum PlayerName {MYRJAM, STIJN}

export(int, "Myrjam", "Stijn") var player_name
export(float) var walk_speed

var left_action
var right_action
var up_action
var down_action

onready var idle_animations = get_node("idle")
onready var walking_animations = get_node("walking")

var last_animation_name = "front"
var last_animation_flipped = false
onready var last_animation = idle_animations.get_node(last_animation_name)

func _ready():
	set_fixed_process(true)
	var player_name_str = "myrjam" if player_name == MYRJAM else "stijn"
	left_action = player_name_str + "_left"
	right_action = player_name_str + "_right"
	up_action = player_name_str + "_up"
	down_action = player_name_str + "_down"

func _fixed_process(delta):
	var direction = Vector2()
	var animation_name = null
	var animation_flipped = false
	if Input.is_action_pressed(up_action):
		direction.y -= 1
		animation_name = "back"
	if Input.is_action_pressed(down_action):
		direction.y += 1
		animation_name = "front"
	if Input.is_action_pressed(left_action):
		direction.x -= 1
		animation_name = "right"
		animation_flipped = true
	if Input.is_action_pressed(right_action):
		direction.x += 1
		animation_name = "right"
	
	if animation_name == null:
		# No input: idle
		set_animation(idle_animations, last_animation_name, last_animation_flipped)
	else:
		# Input: Move & animate
		set_animation(walking_animations, animation_name, animation_flipped)
		move_in_direction(direction, delta)

func move_in_direction(direction, delta):
	var motion = move(direction * walk_speed * delta)
	
	if (is_colliding()):
		var normal = get_collision_normal()
		motion = normal.slide(motion)
		move(motion)

func set_animation(group, name, flipped):
	if self.last_animation != null:
		self.last_animation.set_hidden(true)
	
	var animation = group.get_node(name)
	animation.set_hidden(false)
	animation.flip_h = flipped
	
	self.last_animation_name = name
	self.last_animation_flipped = flipped
	self.last_animation = animation
