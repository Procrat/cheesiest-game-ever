extends Area2D

export(int, "Bloon", "Nachos", "Tickets", "Chocolate milk", "Shaver", "Dress") var item_type

const Player = preload("res://game/player/player.gd")
const utils = preload("res://game/utils.gd")


func _ready():
	connect("body_enter", self, "collide")

func collide(body):
	if body.is_in_group("players"):
		be_picked_up_by(body)

func be_picked_up_by(player):
	INVENTORY.add(item_type)
	set_hidden(true)
	if item_type == INVENTORY.DRESS and player.player_name == Player.MYRJAM:
		var animation_player = player.get_node("animations/fade/player")
		animation_player.play("fade out")
		player.clothing = "normal"
		utils.do_once_after_animation(animation_player, animation_player, "play", ["fade in"])