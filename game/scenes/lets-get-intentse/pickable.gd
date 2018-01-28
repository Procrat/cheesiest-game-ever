extends Area2D

export(Vector2) var drop_displacement = Vector2(0, 0)

var original_owner
var pos_on_player = Vector2(0, -30)
var picked_up = false


func setup(drop_displacement):
	self.drop_displacement = drop_displacement


func _ready():
	if original_owner == null:
		original_owner = get_parent()


func be_picked_up_by(player):
	if picked_up:
		return true
	
	original_owner.remove_child(self)
	player.add_child(self)
	set_pos(pos_on_player)
	picked_up = true
	return true


func be_dropped():
	if not picked_up:
		return true
	
	var player = get_parent()
	player.remove_child(self)
	original_owner.add_child(self)
	translate(player.get_pos() + drop_displacement)
	picked_up = false
	return true