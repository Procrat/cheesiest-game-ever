extends KinematicBody2D

export(float) var walk_speed
export(float) var lick_duration


class Action:
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
		animations.set_flip_h(mango.looking_left)


class IdleAction extends Action:
	func _init(mango).(mango, "idle"):
		pass


class LickAction extends Action:
	enum State {UNSTARTED, STARTED, LICKING, DONE}
	var state = UNSTARTED
	var countdown = 0
	
	func _init(mango).(mango, "lick start"):
		pass
	
	func start():
		.start()
		state = STARTED
		countdown = animation_duration(first_animation_name)
	
	func animation_duration(animation_name):
		var sprite_frames = animations.get_sprite_frames()
		return sprite_frames.get_frame_count(animation_name) / sprite_frames.get_animation_speed(animation_name)
	
	func fixed_process(delta):
		if state == STARTED or state == LICKING:
			countdown -= delta
			if countdown <= 0:
				if state == STARTED:
					lick()
				elif state == LICKING:
					stop_licking()
	
	func lick():
		state = LICKING
		play_animation("lick middle")
		countdown = mango.lick_duration
	
	func stop_licking():
		state = DONE
		play_animation("lick end")


class VomitAction extends Action:
	enum State {UNSTARTED, STARTED, DONE}
	var state = UNSTARTED
	
	var Vomit = preload("res://game/scenes/mango-goes-bananas/mango-animations/vomit.tscn")
	var countdown = 1
	
	func _init(mango).(mango, "vomit"):
		pass
	
	func start():
		.start()
		state = STARTED
	
	func fixed_process(delta):
		if state == STARTED:
			countdown -= delta
			if countdown <= 0:
				spawn_vomit()
				state = DONE
	
	func spawn_vomit():
		var vomit = Vomit.instance()
		vomit.translate(Vector2(31, 35))
		mango.add_child(vomit)
		mango.move_child(vomit, 0)


var action = IdleAction.new(self)
var looking_left = false


func _ready():
	set_fixed_process(true)
	action.start()


func idle():
	if not action extends IdleAction:
		switch_action(IdleAction.new(self))


func vomit():
	if not action extends VomitAction:
		switch_action(VomitAction.new(self))


func lick():
	if not action extends LickAction:
		switch_action(LickAction.new(self))


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