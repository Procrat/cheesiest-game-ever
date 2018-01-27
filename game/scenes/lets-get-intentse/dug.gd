extends KinematicBody2D

export(float) var min_distance_to_stick
export(float) var speed

var initialised = false
var home_base  # Global pos
var followee  # Global pos
var level
var navigation
var animations


func _ready():
	if not initialised:
		set_fixed_process(true)
		home_base = get_global_pos()
		level = get_node("/root/level")
		navigation = level.get_node("navigation")
		animations = get_node("animations")
		for dug_attractor in get_tree().get_nodes_in_group("dug-attractors"):
			dug_attractor.connect("body_enter", self, "stick_encountered_something", [dug_attractor])


func stick_encountered_something(something, stick):
	if something == self:
		followee = stick


func _fixed_process(delta):
	var is_following = followee != null and followee.picked_up
	if not is_following:
		followee = null
	var goal = followee.get_global_pos() if is_following else home_base
	var path = navigation.get_simple_path(pos_relative_to(self.get_global_pos(), level), pos_relative_to(goal, level))
	path.remove(0)
	if path.size() <= 0:
		return
	if not is_following or self.get_global_pos().distance_to(goal) > min_distance_to_stick:
		move_and_slide((path[0] - get_global_pos()).clamped(speed * delta))
	else:
		idle()


func pos_relative_to(target_global_pos, relative_to):
	return relative_to.get_global_transform().xform_inv(target_global_pos)


func idle():
	animations.play("idle")


func move_and_slide(relative_translation):
	var old_pos = get_pos()
	
	var motion = move(relative_translation)
	
	if (is_colliding()):
		var normal = get_collision_normal()
		motion = normal.slide(motion)
		move(motion)
	
	if (get_pos() - old_pos).length() < 1:
		idle()
		return
	
	animations.flip_h = relative_translation.x < 0
	animations.play("running middle")
