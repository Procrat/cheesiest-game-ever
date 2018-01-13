extends Node2D

export(String, FILE, "*.tscn") var next_scene

onready var countdown = get_node("countdown/label")
onready var cinema = get_node("cinema")

func _ready():
	countdown.connect("timeout", self, "time_is_up")
	cinema.connect("reached", self, "cinema_reached")
	
func time_is_up():
	get_tree().change_scene(next_scene)

func cinema_reached(player):
	get_tree().change_scene(next_scene)
