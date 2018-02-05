extends Node2D

export(String, FILE, "*.tscn") var controls_scene
export(String, FILE, "*.tscn") var next_scene

onready var countdown = get_node("countdown")
onready var cinema = get_node("cinema")
onready var end_screen = get_node("end-screen")
onready var retry_button = get_node("end-screen/retry-button")
onready var next_button = get_node("end-screen/next-button")

var players_at_cinema = 0


func _ready():
	countdown.connect("timeout", self, "time_is_up")
	cinema.connect("reached", self, "cinema_reached")
	cinema.connect("left", self, "cinema_left")
	retry_button.connect("pressed", self, "restart")
	next_button.connect("pressed", self, "go_to_next_level")
	
	
func time_is_up():
	show_end_screen(false)


func cinema_reached(player):
	players_at_cinema += 1
	if players_at_cinema >= 2:
		show_end_screen(true)


func cinema_left(player):
	players_at_cinema -= 1


func show_end_screen(in_time):
	get_tree().set_pause(true)
	end_screen.show(in_time)


func restart():
	get_tree().change_scene(controls_scene)
	get_tree().set_pause(false)


func go_to_next_level():
	get_tree().change_scene(next_scene)
	GLOBAL_STATE.ensure_level_unlocked(1)
	get_tree().set_pause(false)
