extends Area2D

signal reached(player)

func _ready():
	connect("body_enter", self, "collide")

func collide(body):
	if body.is_in_group("players"):
		emit_signal("reached", body)