extends Node2D

signal show_hint(message)

const utils = preload("res://game/utils.gd")

class Hint:
	var message
	var timeout
	
	func _init(message, timeout):
		self.message = message
		self.timeout = timeout


var HINTS = [
    # estuary
    [Hint.new("drop a rock in the river", 2)],
    # swing bridge
    [Hint.new("You might be scared all by yourself", 2)],
    # Dug
    [Hint.new("Argh, a dog", 1)],
    # fallen-tree
    [Hint.new("A tree!", 1), Hint.new("liefje to the rescue", 2)],
    # camping
    [Hint.new("woohoo", 0)]
]


onready var areas = get_children()
var players_in_area = []
var current_area = 0


func _ready():
	for area_idx in range(areas.size()):
		players_in_area.append(0)
		
		var area = areas[area_idx]
		area.connect("body_enter", self, "body_enter", [area_idx])
		area.connect("body_exit", self, "body_exit", [area_idx])


func body_enter(body, area_idx):
	if not body.is_in_group("players"):
		return
	
	players_in_area[area_idx] += 1
	if players_in_area[area_idx] >= 2:
		if current_area != area_idx:
			set_hints(area_idx)


func body_exit(body, area_idx):
	if not body.is_in_group("players"):
		return
	
	players_in_area[area_idx] -= 1
	if players_in_area[area_idx] <= 0:
		drop_hints(area_idx)


func set_hints(area_idx):
	emit_signal("show_hint", "")
	current_area = area_idx
	for hint in HINTS[area_idx]:
		utils.do_once_after(hint.timeout, areas[area_idx], self, "show_hint", [hint.message])


func drop_hints(area_idx):
	for child in areas[area_idx].get_children():
		if child extends Timer:
			child.queue_free()


func show_hint(message):
	emit_signal("show_hint", message)
