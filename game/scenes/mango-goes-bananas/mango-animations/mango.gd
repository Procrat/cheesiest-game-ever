extends KinematicBody2D

export(float) var walk_speed
export(float) var idle_duration
export(float) var lick_duration
export(float) var vomit_delay

var utils = preload("res://game/utils.gd")

onready var navigation = get_parent().get_node("navigation")
onready var vomit_location = get_parent().get_node("vomit-location").get_pos()
onready var lick_location = get_parent().get_node("lick-location").get_pos()
onready var fridge_location = get_parent().get_node("fridge-location").get_pos()
onready var fridge = get_parent().get_node("apartment/fridge door")


class Action extends Node:
	signal done
	
	var utils = preload("res://game/utils.gd")
	
	var animations
	
	var mango
	var first_animation_name
	var flipped = false
	
	func _init(mango, first_animation_name):
		self.mango = mango
		self.first_animation_name = first_animation_name
	
	func start():
		animations = mango.get_node("animations")
		play_animation(first_animation_name)
	
	func fixed_process(delta):
		pass
	
	func stop():
		pass
	
	func play_animation(animation_name):
		animations.play(animation_name)
	
	func animation_duration(animation_name):
		var sprite_frames = animations.get_sprite_frames()
		return sprite_frames.get_frame_count(animation_name) / sprite_frames.get_animation_speed(animation_name)


class IdleAction extends Action:
	var countdown
	
	func _init(mango, time).(mango, "idle"):
		countdown = time
	
	func fixed_process(delta):
		if countdown <= 0:
			emit_signal("done")
		countdown -= delta


class WalkAction extends Action:
	var speed
	var navigation
	var goal
	var path
	
	func _init(mango, speed, goal).(mango, "walk"):
		self.speed = speed
		self.goal = goal
	
	func start():
		.start()
		navigation = mango.get_parent().get_node("navigation")
		path = navigation.get_simple_path(mango.get_pos(), goal)
		# The first point in the path is Mango's position, but where already there
		path.remove(0)
	
	func fixed_process(delta):
		if path.size() <= 0:
			return
		
		var current_pos = mango.get_pos()
		var direction = path[0] - current_pos
		var advancement = direction.clamped(speed * delta)
		var new_pos = current_pos + advancement
		if new_pos != current_pos:
			mango.set_pos(new_pos)
			mango.look_in(direction)
		else:
			path.remove(0)
			if path.size() <= 0:
				emit_signal("done")


class JumpAction extends Action:
	enum State {UNSTARTED, STARTED, AIRBORN, TOUCHDOWN, DONE}
	var state = UNSTARTED
	
	var countdown
	var airborn_delay = 16.0 / 24.0
	var touchdown_delay = 3.0 / 24.0
	
	func _init(mango).(mango, "jump up"):
		pass
	
	func start():
		.start()
		countdown = airborn_delay
		state = STARTED
		mango.look_right()
	
	func fixed_process(delta):
		if state == STARTED or state == AIRBORN or state == TOUCHDOWN:
			if countdown <= 0:
				if state == STARTED:
					fly_my_pretty()
				elif state == AIRBORN:
					touchdown()
				elif state == TOUCHDOWN:
					state = DONE
					emit_signal("done")
			else:
				if state == AIRBORN:
					mango.translate(Vector2(500 * delta, -100 * delta))
				if state == TOUCHDOWN:
					mango.translate(Vector2(100 * delta, 0))
			countdown -= delta
	
	func fly_my_pretty():
		state = AIRBORN
		countdown = touchdown_delay
	
	func touchdown():
		state = TOUCHDOWN
		countdown = animation_duration("jump up") - airborn_delay - touchdown_delay


class LickAction extends Action:
	enum State {UNSTARTED, STARTED, LICKING, FINISHING, DONE}
	var state = UNSTARTED
	var countdown = 0
	
	func _init(mango).(mango, "lick start"):
		pass
	
	func start():
		.start()
		state = STARTED
		mango.look_right()
		countdown = animation_duration(first_animation_name)
	
	func fixed_process(delta):
		if state == STARTED or state == LICKING or state == FINISHING:
			if countdown <= 0:
				if state == STARTED:
					lick()
				elif state == LICKING:
					stop_licking()
				elif state == FINISHING:
					state = DONE
					emit_signal("done")
			countdown -= delta
	
	func lick():
		state = LICKING
		play_animation("lick middle")
		countdown = mango.lick_duration
	
	func stop_licking():
		state = FINISHING
		play_animation("lick end")
		countdown = animation_duration("lick end")


class VomitAction extends Action:
	enum State {UNSTARTED, STARTED, VOMITING, DONE}
	var state = UNSTARTED
	
	var Vomit = preload("res://game/scenes/mango-goes-bananas/mango-animations/vomit.tscn")
	var countdown
	var vomit
	
	func _init(mango, vomit_delay).(mango, "vomit"):
		countdown = vomit_delay
	
	func start():
		.start()
		state = STARTED
		mango.look_right()
	
	func fixed_process(delta):
		if state == STARTED or state == VOMITING:
			if countdown <= 0:
				if state == STARTED:
					spawn_vomit()
					state = VOMITING
					countdown = vomit_duration_left()
				elif state == VOMITING:
					state = DONE
					emit_signal("done")
			countdown -= delta
	
	func stop():
		vomit.queue_free()
	
	func vomit_duration_left():
		var sprite_frames = animations.get_sprite_frames()
		return (sprite_frames.get_frame_count("vomit") - animations.get_frame()) / sprite_frames.get_animation_speed("vomit")
	
	func spawn_vomit():
		vomit = Vomit.instance()
		vomit.translate(Vector2(36, -26))
		mango.add_child(vomit)
		mango.move_child(vomit, 0)


class FridgeAction extends Action:
	enum State {UNSTARTED, ATTEMPTING, OPENING, DONE}
	var state = UNSTARTED
	
	var fridge
	
	func _init(mango, fridge).(mango, "opens fridge"):
		self.fridge = fridge
	
	func start():
		.start()
		state = ATTEMPTING
		mango.look_left()
		utils.do_once_after(34.0 / 24.0, mango, self, "open_fridge")
	
	func open_fridge():
		state = OPENING
		fridge.play("open")
		utils.do_once_after_animation(animations, self, "done")
	
	func done():
		state = DONE
		emit_signal("done")


onready var animations = get_node("animations")
onready var action = IdleAction.new(self, 1)


func _ready():
	set_fixed_process(true)
	action.start()
	action.connect("done", self, "go_crazy")
	randomize()


func go_crazy():
	# Choose something random to do
	var possible_actions = ["go_and_idle", "go_and_vomit", "go_and_lick", "go_and_open_fridge"]
	var corresponding_action_classes = [null, VomitAction, LickAction, FridgeAction]
	for class_idx in range(corresponding_action_classes.size()):
		var clazz = corresponding_action_classes[class_idx]
		if clazz != null and action extends clazz:
			possible_actions.remove(class_idx)
			break
	var new_action = possible_actions[randi() % possible_actions.size()]
	print("Mango decides to ", new_action)
	call(new_action)


func go_and_idle():
	var idle_location = random_accessible_location()
	while navigation.get_simple_path(get_pos(), idle_location).size() < 2 and get_pos().distance_to(idle_location) < 150:
		idle_location = random_accessible_location()
	go_and_do(idle_location, "idle")


func random_accessible_location():
	var random_close_point = get_pos() + Vector2((randi() % 1000) + 50, (randi() % 1000) + 50)
	return navigation.get_closest_point(random_close_point)


func idle():
	do_and(IdleAction.new(self, idle_duration), "go_crazy")


func go_and_vomit():
	go_and_do(vomit_location, "vomit")


func vomit():
	do_and(VomitAction.new(self, vomit_delay), "go_crazy")


func go_and_lick():
	go_and_do(lick_location, "jump_and_lick")


func jump_and_lick():
	do_and(JumpAction.new(self), "lick")


func lick():
	do_and(LickAction.new(self), "go_crazy")


func go_and_open_fridge():
	go_and_do(fridge_location, "open_fridge")


func open_fridge():
	do_and(FridgeAction.new(self, fridge), "go_crazy")


func go_and_do(location, action_name):
	do_and(WalkAction.new(self, walk_speed, location), action_name)


func do_and(action, next_action_name):
	action.connect("done", self, next_action_name)
	switch_action(action)


func look_left():
	animations.set_flip_h(true)


func look_right():
	animations.set_flip_h(false)


func look_in(direction):
	if direction.x < 0:
		look_left()
	else:
		look_right()


func interrupt():
	if action extends LickAction or action extends VomitAction:
		switch_action(IdleAction.new(self))
		# TODO should be jump action


func switch_action(action):
	self.action.stop()
	action.start()
	self.action = action


func _fixed_process(delta):
	action.fixed_process(delta)
