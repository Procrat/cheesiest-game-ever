extends Node2D

export(String, FILE, "*.tscn") var lvl1
export(PackedScene) var instructions_lvl1
export(String, FILE, "*.tscn") var lvl2
export(PackedScene) var instructions_lvl2
export(String, FILE, "*.tscn") var lvl3
export(PackedScene) var instructions_lvl3
export(String, FILE, "*.tscn") var lvl4
export(PackedScene) var instructions_lvl4


onready var buttons = get_node("buttons").get_children()
onready var instructions_scenes = [instructions_lvl1, instructions_lvl2, instructions_lvl3, instructions_lvl4]
onready var level_names = [lvl1, lvl2, lvl3, lvl4]

var instructions_scene
var instructions_idx


func _ready():
	for level_idx in range(buttons.size()):
		buttons[level_idx].connect("pressed", self, "show_instructions", [level_idx])
	
	for level_idx in range(GLOBAL_STATE.highest_level_unlocked + 1, buttons.size()):
		buttons[level_idx].set_disabled(true)
		buttons[level_idx].set_text("")


func show_instructions(level_idx):
	if instructions_scene != null:
		if instructions_idx == level_idx:
			return
		remove_child(instructions_scene)
	var instructions = instructions_scenes[level_idx].instance()
	add_child(instructions)
	instructions.get_node("play-button").connect("pressed", self, "start_level", [level_idx])
	instructions_scene = instructions
	instructions_idx = level_idx


func start_level(level_idx):
	get_tree().change_scene(level_names[level_idx])
