extends Node2D

onready var draw_progress = get_node("ui/VBoxContainer/Control/draw-progress")
onready var study_progress = get_node("ui/VBoxContainer/Control 2/study-progress")
onready var countdown = get_node("ui/countdown")
onready var end_screen = get_node("end-screen/end-screen")

var mischief_ignored = {}


func _ready():
	countdown.connect("timeout", self, "show_end_screen")


func mischief_missed(mischief):
	mischief_ignored[mischief] = mischief


func show_end_screen():
	var drawn_enough = draw_progress.has_done_enough()
	var studied_enough = study_progress.has_done_enough()
	end_screen.show(mischief_ignored.keys(), drawn_enough, studied_enough)
