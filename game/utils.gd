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