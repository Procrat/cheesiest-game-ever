extends Node

var highest_level_unlocked = 0
var is_single_player = false

func ensure_level_unlocked(level):
	if level > highest_level_unlocked:
		highest_level_unlocked = level
