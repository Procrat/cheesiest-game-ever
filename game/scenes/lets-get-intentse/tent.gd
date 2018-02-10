extends Area2D

export(PackedScene) var cut_scene

var utils = preload("res://game/utils.gd")

var players_arrived = 0


func _ready():
	connect("body_enter", self, "body_enter")
	connect("body_exit", self, "body_exit")


func body_enter(body):
	if body.is_in_group("players"):
		players_arrived += 1
		if players_arrived >= 2:
			SFX.play("wheee-together")
			utils.do_once_after(2, self, self, "win_at_life")
		else:
			body.beckon()


func body_exit(body):
	if body.is_in_group("players"):
		players_arrived -= 1
		body.stop_beckoning()


func win_at_life():
	get_tree().change_scene_to(cut_scene)