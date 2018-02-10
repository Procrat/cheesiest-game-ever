extends Node

export(PackedScene) var intro_scene


func _ready():
	get_node("play alone").connect("pressed", self, "play", [true])
	get_node("play together").connect("pressed", self, "play", [false])


func play(is_single_player):
	GLOBAL_STATE.is_single_player = is_single_player
	get_tree().change_scene_to(intro_scene)
