extends Area2D

export(String, FILE, "*.tscn") var next_scene

var players_arrived = 0


func _ready():
	connect("body_enter", self, "body_enter")


func body_enter(body):
	if body.is_in_group("players"):
		players_arrived += 1
		if players_arrived >= 2:
			get_tree().change_scene(next_scene)
		else:
			body.beckon()