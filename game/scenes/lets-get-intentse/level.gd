extends Node2D


onready var tent = get_node("tent")
onready var i_give_up_button = get_node("i-give-up")


func _ready():
	i_give_up_button.connect("pressed", self, "give_up")


func give_up():
	for player in get_tree().get_nodes_in_group("players"):
		player.teleport(tent.get_global_pos())