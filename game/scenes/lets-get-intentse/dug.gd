extends KinematicBody2D

export(float) var min_distance_to_stick
export(float) var speed

var initialised = false
var home_base  # Global pos
var followee  # Global pos

onready var level = get_node("/root/level")
onready var navigation = level.get_node("navigation")
onready var animations = get_node("animations")


func _ready():
	if not initialised:
		set_fixed_process(true)
		home_base = get_global_pos()
		for dug_attractor in get_tree().get_nodes_in_group("dug-attractors"):
			dug_attractor.connect("body_enter", self, "stick_encountered_something", [dug_attractor])


func stick_encountered_something(something, stick):
	if something == self:
		followee = stick


func _fixed_process(delta):
	var is_following = followee != null and followee.picked_up
	if not is_following:
		followee = null
	
	var goal
	if is_following:
		var enemy_path = navigation.get_simple_path(pos_relative_to(followee.get_global_pos(), level), pos_relative_to(home_base, level))
		goal = find_defending_position(enemy_path, 100)
	else:
		goal = home_base
	
	var path = navigation.get_simple_path(pos_relative_to(get_global_pos(), level), pos_relative_to(goal, level))
	path.remove(0)
	if path.size() <= 0:
		return
	
	move_and_slide((path[0] - get_global_pos()).clamped(speed * delta))


func find_defending_position(path, distance_from_start):
	var distance_left = distance_from_start
	for i in range(path.size() - 1):
		var path_diff = path[i+1] - path[i]
		var part_length = path_diff.length()
		if part_length > distance_left:
			return path[i] + path_diff.clamped(distance_left)
		else:
			distance_left -= part_length
	return path[path.size() - 1]


func pos_relative_to(target_global_pos, relative_to):
	return relative_to.get_global_transform().xform_inv(target_global_pos)


func move_and_slide(relative_translation):
	var old_pos = get_pos()
	
	var motion = move(relative_translation)
	
	if (is_colliding()):
		var normal = get_collision_normal()
		motion = normal.slide(motion)
		move(motion)
	
	if (get_pos() - old_pos).length() < 1:
		animations.play("idle")
	else:
		animations.flip_h = relative_translation.x < 0
		animations.play("running middle")
