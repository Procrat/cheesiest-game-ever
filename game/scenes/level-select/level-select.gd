extends Node2D

export(String, FILE, "*.tscn") var controls_lvl1
export(String, FILE, "*.tscn") var controls_lvl2
export(String, FILE, "*.tscn") var controls_lvl3
export(String, FILE, "*.tscn") var controls_lvl4

onready var buttons = get_node("buttons").get_children()
onready var levels = [controls_lvl1, controls_lvl2, controls_lvl3, controls_lvl4]

func _ready():
	for level_idx in range(buttons.size()):
		buttons[level_idx].connect("pressed", self, "start_level", [level_idx])
	
	for level_idx in range(GLOBAL_STATE.highest_level_unlocked + 1, buttons.size()):
		buttons[level_idx].set_disabled(true)

func start_level(level):
	get_tree().change_scene(levels[level])
