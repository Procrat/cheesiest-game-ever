extends AnimatedSprite

signal cleaned

var utils = preload("res://game/utils.gd")

onready var fridge_location = get_node("/root/level/mischief/fridge-location")
onready var fridge_door = get_node("/root/level/apartment/fridge door")


func start(parent):
	parent.add_child(self)
	get_sprite_frames().set_animation_speed("cleaning-progress", 200)
	play("mischief-progress")
	utils.do_once_after_animation(self, self, "play", ["mischief-flicker"])


func interrupt():
	if get_parent() == fridge_location:
		fridge_door.play("close")
	cleaned()


func clean():
	play("cleaning-progress")
	if get_parent() == fridge_location:
		fridge_door.play("close")
	utils.do_once_after_animation(self, self, "cleaned")


func cleaned():
	emit_signal("cleaned")


func stop_cleaning():
	stop()