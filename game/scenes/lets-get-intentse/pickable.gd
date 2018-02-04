extends Area2D

export(Vector2) var pos_on_player_before_picking_up = Vector2(0, 0)
export(Vector2) var pos_on_player_after_picking_up = Vector2(0, -30)
export(float) var bend_down_duration = .5
export(float) var lift_duration = .5
export(Vector2) var drop_displacement = Vector2(0, 0)

var utils = preload("res://game/utils.gd")

var original_owner
var picked_up = false
var pick_up_timer
var being_lifted = false


func setup(pos_on_player_before_picking_up, pos_on_player_after_picking_up, bend_down_duration, lift_duration, drop_displacement):
	self.pos_on_player_before_picking_up = pos_on_player_before_picking_up
	self.pos_on_player_after_picking_up = pos_on_player_after_picking_up
	self.bend_down_duration = bend_down_duration
	self.lift_duration = lift_duration
	self.drop_displacement = drop_displacement


func _ready():
	if original_owner == null:
		original_owner = get_parent()
	set_fixed_process(true)


func _fixed_process(delta):
	if being_lifted:
		var diff = pos_on_player_after_picking_up - pos_on_player_before_picking_up
		var translation = diff.clamped(diff.length() * delta / lift_duration)
		translate(translation)


func be_picked_up_by(player):
	if picked_up:
		return true
	
	picked_up = true
	original_owner.remove_child(self)
	player.add_child(self)
	set_pos(pos_on_player_before_picking_up)
	utils.do_once_after(bend_down_duration, self, self, "start_being_lifted")
	return true


func start_being_lifted():
	being_lifted = true
	utils.do_once_after(lift_duration, self, self, "done_being_lifted")


func done_being_lifted():
	being_lifted = false


func be_dropped():
	if not picked_up:
		return true
	
	var player = get_parent()
	player.remove_child(self)
	original_owner.add_child(self)
	translate(player.get_pos() + drop_displacement)
	picked_up = false
	return true