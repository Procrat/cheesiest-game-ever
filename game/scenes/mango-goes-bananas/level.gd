extends Node2D

export(String, FILE, "*.tscn") var controls_scene
export(String, FILE, "*.tscn") var next_scene

var utils = preload("res://game/utils.gd")

onready var draw_progress = get_node("ui/VBoxContainer/Control/draw-progress")
onready var study_progress = get_node("ui/VBoxContainer/Control 2/study-progress")
onready var countdown = get_node("ui/countdown")
onready var end_screen = get_node("end-screen/end-screen")
onready var retry_button = get_node("end-screen/end-screen/retry-button")
onready var next_button = get_node("end-screen/end-screen/next-button")

var mischief_ignored = {}


func _ready():
	countdown.connect("timeout", self, "show_end_screen")
	retry_button.connect("pressed", self, "restart")
	next_button.connect("pressed", self, "go_to_next_level")


func mischief_missed(mischief):
	mischief_ignored[mischief] = mischief


func show_end_screen():
	get_tree().set_pause(true)
	var drawn_enough = draw_progress.has_done_enough()
	var studied_enough = study_progress.has_done_enough()
	end_screen.show(mischief_ignored.keys(), drawn_enough, studied_enough)


func restart():
	get_tree().change_scene(controls_scene)
	get_tree().set_pause(false)


func go_to_next_level():
	get_tree().change_scene(next_scene)
	GLOBAL_STATE.ensure_level_unlocked(2)
	get_tree().set_pause(false)
