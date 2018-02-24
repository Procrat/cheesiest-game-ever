extends Node


class TimerAction extends Node:
	var timer
	
	func _init(wait_time, attachee, target, method, binds=[]):
		timer = Timer.new()
		timer.set_wait_time(wait_time)
		timer.set_one_shot(true)
		timer.connect("timeout", target, method, binds)
		attachee.add_child(timer)
		timer.start()
	
	func cancel():
		if timer != null:
			timer.stop()
			timer.queue_free()
			timer = null


class SignalAction extends Node:
	var emitter
	var the_signal
	var target
	var method
	var binds
	
	func _init(emitter, the_signal, target, method, binds=[]):
		self.emitter = emitter
		self.the_signal = the_signal
		self.target = target
		self.method = method
		self.binds = binds
		emitter.connect(the_signal, self, "run")
	
	func run():
		cancel()
		return target.callv(method, binds)
	
	func cancel():
		emitter.disconnect(the_signal, self, "run")


static func do_once_after(wait_time, attachee, target, method, binds=[]):
	return TimerAction.new(wait_time, attachee, target, method, binds)


static func do_once_after_animation(animated_sprite, target, method, binds=[]):
	return SignalAction.new(animated_sprite, "finished", target, method, binds)


static func set_animation_duration(animated_sprite, animation_name, duration):
	var sprites = animated_sprite.get_sprite_frames().duplicate(true)
	animated_sprite.set_sprite_frames(sprites)
	var speed = sprites.get_frame_count(animation_name) / duration
	
	sprites.set_animation_speed(animation_name, speed)

static func get_animation_duration(animated_sprite, animation_name):
	var sprites = animated_sprite.get_sprite_frames()
	return sprites.get_frame_count(animation_name) / sprites.get_animation_speed(animation_name)


static func get_total_animation_duration(animated_sprite, animation_names):
	var sum = 0
	for animation_name in animation_names:
		sum += get_animation_duration(animated_sprite, animation_name)
	return sum
