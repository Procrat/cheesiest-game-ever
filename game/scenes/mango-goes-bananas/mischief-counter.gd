extends Node2D

onready var failed = get_node("failed")
onready var total = get_node("total")


func mischief_started():
	total.set_text(str(int(total.get_text()) + 1))


func mischief_missed():
	failed.set_text(str(int(failed.get_text()) + 1))
