extends KinematicBody2D

export(float) var walk_speed
export(float) var lick_duration

class Action:
	var level
	var animation_name
	var animation
	
	func _init(level, animation_name):
		self.level = level
		self.animation_name = animation_name
	
	func start():
		switch_animation(animation_name)
	
	func fixed_process(delta):
		pass
	
	func stop():
		animation.hide()
	
	func switch_animation(animation_name):
		if animation != null:
			animation.hide()
		
		animation = level.get_node(animation_name)
		animation.set_flip_h(level.looking_left)
		animation.show()
		animation.set_frame(0)


class IdleAction extends Action:
	func _init(level).(level, "idle"):
		pass


class LickAction extends Action:
	enum State {UNSTARTED, STARTED, LICKING, DONE}
	var state = UNSTARTED
	var countdown = 0
	
	func _init(level).(level, "lick start"):
		pass
	
	func start():
		.start()
		state = STARTED
		countdown = animation_duration(animation)
	
	func animation_duration(animation):
		var sprite_frames = animation.get_sprite_frames()
		return sprite_frames.get_frame_count("default") / sprite_frames.get_animation_speed("default")
	
	func fixed_process(delta):
		print("lick process")
		if state == STARTED or state == LICKING:
			countdown -= delta
			if countdown <= 0:
				if state == STARTED:
					lick()
				elif state == LICKING:
					stop_licking()
	
	func lick():
		state = LICKING
		switch_animation("lick middle")
		countdown = level.lick_duration
	
	func stop_licking():
		state = DONE
		switch_animation("lick end")


class VomitAction extends Action:
	enum State {UNSTARTED, STARTED, DONE}
	var state = UNSTARTED
	
	var Vomit = preload("res://game/scenes/mango-goes-bananas/mango-animations/vomit.tscn")
	var countdown = 1
	
	func _init(level).(level, "vomit"):
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
		level.add_child(vomit)
		level.move_child(vomit, 0)


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
	print("setting action", action)
	self.action.stop()
	action.start()
	self.action = action


func _fixed_process(delta):
	action.fixed_process(delta)