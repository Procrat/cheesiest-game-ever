extends Node2D

onready var hints = get_node("hints")
onready var tent = get_node("tent")
onready var i_give_up_button = get_node("i-give-up")
onready var hints_label = get_node("hints-label")
onready var current_player = get_node("Stijn")


func _ready():
	hints.connect("show_hint", hints_label, "set_text")
	i_give_up_button.connect("pressed", self, "give_up")
	if GLOBAL_STATE.is_single_player:
		set_process_input(true)
	else:
		current_player.get_node("twinkle").hide()


func _input(event):
	if event.is_action_released("switch"):
		current_player.is_npc = true
		var twinkle = current_player.get_node("twinkle")
		current_player.remove_child(twinkle)
		
		current_player = current_player.significant_other
		
		current_player.is_npc = false
		current_player.add_child(twinkle)


func give_up():
	for player in get_tree().get_nodes_in_group("players"):
		player.teleport(tent.get_global_pos())