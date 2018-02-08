extends AnimatedSprite

signal cleaned

enum Mischief {MEAT, VOMIT, FRIDGE, PEE}

var utils = preload("res://game/utils.gd")

onready var level = get_node("/root/level")
onready var fridge_location = level.get_node("mischief/fridge-location")
onready var fridge_door = level.get_node("apartment/fridge door")

var mischief_kind
var residue


func start(mischief_kind, parent):
	self.mischief_kind = mischief_kind
	parent.add_child(self)
	get_sprite_frames().set_animation_speed("cleaning-progress", 80)
	play("mischief-progress")
	level.mischief_started(mischief_kind)
	utils.do_once_after_animation(self, self, "it_s_almost_too_laaaate")


func spawn(residue):
	self.residue = residue
	var scale = residue.get_global_scale()
	add_child(residue)
	residue.set_global_scale(scale)


func it_s_almost_too_laaaate():
	play("mischief-flicker")
	utils.do_once_after(2, self, self, "it_s_too_late_now_muahahaha")


func it_s_too_late_now_muahahaha():
	level.mischief_missed(mischief_kind)
	attach_residue_to_level()
	queue_free()


func attach_residue_to_level():
	if residue == null:
		return
	
	var pos = residue.get_global_pos()
	var scale = residue.get_global_scale()
	remove_child(residue)
	level.add_child(residue)
	residue.set_global_pos(pos)
	residue.set_global_scale(scale)


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