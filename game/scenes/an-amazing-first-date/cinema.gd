extends Area2D

signal reached(player)
signal left(player)

func _ready():
	connect("body_enter", self, "body_enter")
	connect("body_exit", self, "body_exit")

func body_enter(body):
	if body.is_in_group("players"):
#		body.beckon()
		emit_signal("reached", body)


func body_exit(body):
	if body.is_in_group("players"):
#		body.stop_beckoning()
		emit_signal("left", body)
