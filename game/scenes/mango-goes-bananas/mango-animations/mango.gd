extends KinematicBody2D

export(float) var walk_speed
export(float) var idle_duration
export(float) var lick_duration
export(float) var vomit_delay

var utils = preload("res://game/utils.gd")

onready var navigation = get_parent().get_node("navigation")
onready var vomit_location = get_parent().get_node("mischief/vomit-location")
onready var jump_to_lick_location = get_parent().get_node("mischief/jump-to-lick-location")
onready var lick_location = get_parent().get_node("mischief/lick-location")
onready var fridge_location = get_parent().get_node("mischief/fridge-location")
onready var fridge = get_parent().get_node("apartment/fridge door")
onready var jump_to_pee_location = get_parent().get_node("mischief/jump-to-pee-location")
onready var pee_location = get_parent().get_node("mischief/pee-location")


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
		animations.play(first_animation_name)
	
	func fixed_process(delta):
		pass
	
	func stop():
		emit_signal("done")
	
	func animation_duration(animation_name):
		var sprite_frames = animations.get_sprite_frames()
		return sprite_frames.get_frame_count(animation_name) / sprite_frames.get_animation_speed(animation_name)


class MischiefAction extends Action:
	const MischiefKind = preload("res://game/scenes/mango-goes-bananas/mischief/mischief.gd").Mischief
	const Mischief = preload("res://game/scenes/mango-goes-bananas/mischief/mischief.tscn")
	
	var location
	var kind
	var mischief
	var interrupted = false
	
	func _init(mango, first_animation_name, location, kind).(mango, first_animation_name):
		self.location = location
		self.kind = kind
	
	func start():
		.start()
		mischief = Mischief.instance()
		mischief.start(kind, location)
	
	func interrupt():
		interrupted = true
		mischief.interrupt()
		stop()


class IdleAction extends Action:
	var countdown
	
	func _init(mango, time).(mango, "idle"):
		countdown = time
	
	func fixed_process(delta):
		if countdown <= 0:
			stop()
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
				stop()


class JumpAction extends Action:
	enum State {STATIC, AIRBORN, TOUCHDOWN}
	var state = STATIC
	
	var airborn_delay = 16.0 / 24.0
	var touchdown_delay = 3.0 / 24.0
	
	func _init(mango).(mango, "jump up"):
		pass
	
	func start():
		.start()
		mango.look_right()
		utils.do_once_after(airborn_delay, mango, self, "fly_my_pretty")
	
	func fixed_process(delta):
		if state == AIRBORN:
			mango.translate(Vector2(500 * delta, -100 * delta))
		elif state == TOUCHDOWN:
			mango.translate(Vector2(100 * delta, 0))
	
	func fly_my_pretty():
		state = AIRBORN
		utils.do_once_after(touchdown_delay, mango, self, "touchdown")
	
	func touchdown():
		state = TOUCHDOWN
		utils.do_once_after_animation(animations, self, "stop")


class JumpDownAction extends Action:
	enum State {STATIC, AIRBORN, TOUCHDOWN}
	var state = STATIC
#	
	var airborn_delay = 11.0 / 24.0
	var touchdown_delay = 7.0 / 24.0
	
	func _init(mango).(mango, "jump down"):
		pass
	
	func start():
		.start()
		mango.look_left()
		utils.do_once_after(airborn_delay, mango, self, "fly_my_pretty")
	
	func fixed_process(delta):
		if state == AIRBORN:
			mango.translate(Vector2(-350 * delta, 0))
	
	func fly_my_pretty():
		state = AIRBORN
		utils.do_once_after(touchdown_delay, mango, self, "touchdown")
	
	func touchdown():
		state = TOUCHDOWN
		utils.do_once_after_animation(animations, self, "stop")


class LickAction extends MischiefAction:
	func _init(mango).(mango, "lick start", mango.lick_location, MischiefKind.MEAT):
		pass
	
	func start():
		.start()
		mango.look_right()
		utils.do_once_after_animation(animations, self, "lick")
	
	func lick():
		if interrupted:
			return
		animations.play("lick middle")
		utils.do_once_after(mango.lick_duration, mango, self, "stop_licking")
	
	func stop_licking():
		animations.play("lick end")
		utils.do_once_after_animation(animations, self, "stop")
	
	func interrupt():
		interrupted = true
		mischief.interrupt()
		stop_licking()


class VomitAction extends MischiefAction:
	var Vomit = preload("res://game/scenes/mango-goes-bananas/mango-animations/vomit.tscn")
	var vomit
	
	func _init(mango).(mango, "vomit", mango.vomit_location, MischiefKind.VOMIT):
		pass
	
	func start():
		.start()
		mango.look_right()
		utils.do_once_after(mango.vomit_delay, mango, self, "spawn_vomit")
	
	func spawn_vomit():
		if interrupted:
			return
		vomit = Vomit.instance()
		mischief.add_child(vomit)
		utils.do_once_after_animation(animations, self, "stop")
	
	func interrupt():
		interrupted = true
		mischief.interrupt()
		stop()


class FridgeAction extends MischiefAction:
	var fridge
	
	func _init(mango, fridge).(mango, "opens fridge", mango.fridge_location, MischiefKind.FRIDGE):
		self.fridge = fridge
	
	func start():
		.start()
		mango.look_left()
		utils.do_once_after(34.0 / 24.0, mango, self, "open_fridge")
	
	func open_fridge():
		if interrupted:
			return
		fridge.play("open")
		utils.do_once_after_animation(animations, self, "start_licking")
	
	func start_licking():
		if interrupted:
			return
		animations.play("lick start")
		utils.do_once_after_animation(animations, animations, "play", ["lick middle"])
		utils.do_once_after(4, mango, self, "stopping")
	
	func stopping():
		animations.play("lick end")
		utils.do_once_after_animation(animations, self, "stop")
	
	func interrupt():
		interrupted = true
		mischief.interrupt()
		stopping()


class PeeAction extends MischiefAction:
	var Pee = preload("res://game/scenes/mango-goes-bananas/mango-animations/pipi.tscn")
	var pee
	
	func _init(mango).(mango, "pipi start", mango.pee_location, MischiefKind.PEE):
		pass
	
	func start():
		.start()
		mango.look_right()
		utils.do_once_after_animation(animations, self, "pee")
	
	func pee():
		if interrupted:
			return
		animations.play("pipi middle")
		pee = Pee.instance()
		mischief.add_child(pee)
		utils.do_once_after_animation(animations, self, "stop_peeing")
	
	func stop_peeing():
		animations.play("pipi end")
		utils.do_once_after_animation(animations, self, "stop")
	
	func interrupt():
		interrupted = true
		mischief.interrupt()
		stop_peeing()


onready var animations = get_node("animations")
onready var action = IdleAction.new(self, 1)


func _ready():
	set_fixed_process(true)
	action.start()
	action.connect("done", self, "go_crazy")
	randomize()


func go_crazy():
	# Choose something random to do
	var possible_actions = ["go_and_idle", "go_and_vomit", "go_and_lick", "go_and_open_fridge", "go_and_pee"]
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
	go_and_do(vomit_location.get_pos(), "vomit")


func vomit():
	do_and(VomitAction.new(self), "go_crazy")


func go_and_lick():
	go_and_do(jump_to_lick_location.get_pos(), "jump_and_lick")


func jump_and_lick():
	do_and(JumpAction.new(self), "lick")


func lick():
	do_and(LickAction.new(self), "jump_down")


func jump_down():
	do_and(JumpDownAction.new(self), "go_crazy")


func go_and_open_fridge():
	go_and_do(fridge_location.get_pos(), "open_fridge")


func open_fridge():
	do_and(FridgeAction.new(self, fridge), "go_crazy")


func go_and_pee():
	go_and_do(jump_to_pee_location.get_pos(), "jump_and_pee")


func jump_and_pee():
	do_and(JumpAction.new(self), "pee")


func pee():
	do_and(PeeAction.new(self), "go_crazy")


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
	if action extends MischiefAction:
		action.interrupt()


func switch_action(action):
	action.start()
	self.action = action


func _fixed_process(delta):
	action.fixed_process(delta)
