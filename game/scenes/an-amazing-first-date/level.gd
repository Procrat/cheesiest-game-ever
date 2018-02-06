extends Node2D

onready var countdown = get_node("countdown")
onready var cinema = get_node("cinema")
onready var end_screen = get_node("end-screen")

var players_at_cinema = 0


func _ready():
	countdown.connect("timeout", self, "time_is_up")
	cinema.connect("reached", self, "cinema_reached")
	cinema.connect("left", self, "cinema_left")
	
	
func time_is_up():
	show_end_screen(false)


func cinema_reached(player):
	players_at_cinema += 1
	if players_at_cinema >= 2:
		show_end_screen(true)


func cinema_left(player):
	players_at_cinema -= 1


func show_end_screen(in_time):
	end_screen.show(in_time)
