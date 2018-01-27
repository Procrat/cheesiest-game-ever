extends Node


func _ready():
	set_process(true)


func _process(delta):
	order_sprites_according_to_y()


func order_sprites_according_to_y():
	for object in get_tree().get_nodes_in_group("moving"):
		object.set_z(object.get_pos().y)
