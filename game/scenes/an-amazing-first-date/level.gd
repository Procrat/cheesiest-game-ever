extends Node2D

onready var countdown = get_node("countdown")
onready var cinema = get_node("cinema")
onready var end_screen = get_node("end-screen")
onready var objects = get_node("objects")

var players_at_cinema = 0


func _ready():
	countdown.connect("timeout", self, "time_is_up")
	cinema.connect("reached", self, "cinema_reached")
	cinema.connect("left", self, "cinema_left")
	if GLOBAL_STATE.is_single_player:
		objects.get_node("multiplayer").hide()
		objects.get_node("singleplayer").show()
		var myrjam = get_node("Myrjam")
		myrjam.set_pos(cinema.get_pos() + Vector2(-60, -50))
		myrjam.clothing = "normal"
		INVENTORY.add(INVENTORY.DRESS)
	
	
func time_is_up():
	show_end_screen(false)


func cinema_reached(player):
	players_at_cinema += 1
	player.beckon()
	if players_at_cinema >= 2:
		show_end_screen(true)


func cinema_left(player):
	players_at_cinema -= 1
	player.stop_beckoning()


func show_end_screen(in_time):
	end_screen.show(in_time)
