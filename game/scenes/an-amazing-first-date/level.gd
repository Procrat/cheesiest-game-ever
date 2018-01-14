extends Node2D

export(String, FILE, "*.tscn") var controls_scene

onready var countdown = get_node("countdown")
onready var cinema = get_node("cinema")
onready var end_screen = get_node("end-screen")
onready var retry_button = get_node("end-screen/retry-button")

func _ready():
	countdown.connect("timeout", self, "time_is_up")
	cinema.connect("reached", self, "cinema_reached")
	retry_button.connect("pressed", self, "restart")
	
func time_is_up():
	show_end_screen(false)

func cinema_reached(player):
	show_end_screen(true)

func show_end_screen(in_time):
	get_tree().set_pause(true)
	end_screen.show(in_time)

func restart():
	get_tree().change_scene(controls_scene)
	get_tree().set_pause(false)
