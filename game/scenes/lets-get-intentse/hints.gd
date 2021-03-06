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
    [Hint.new("The river is too wide to cross!", 15), 
	(Hint.new("Remember, you can pick stuff up by pressing Space or Shift.", 30) if not GLOBAL_STATE.is_single_player
		else Hint.new("Remember, you can pick stuff up by pressing Space and switch between players by pressing Shift.", 30)), 
	Hint.new("You'll need a stepstone...", 45),
	Hint.new("Those rocks at the top look like they might be useful!", 65), 
	Hint.new("I think you'll need two of them. Try working together!", 85), 
	Hint.new("Crossing at the narrowest part of the river sounds like a good plan. (Although not in real life.)", 105), 
	Hint.new("There is no shame in clicking the \"I give up!\"-button, you know.", 135)],
    # swing bridge
    [Hint.new("Uh-oh. There's a danger sign at the swing bridge. That looks scary!", 15), 
	Hint.new("That is one long swingbridge. Luckily love conquers all!", 30), 
	Hint.new("If you keep your loved ones close, you might feel less scared.", 60), 
	Hint.new("Try crossing together!", 75), 
	Hint.new("There is no shame in clicking the \"I give up!\"-button, you know.", 120)],
    # Dug
    [Hint.new("That dog doesn't look like he will move without an incentive to do so.", 15), 
	Hint.new("This dog hates squirrels and cones of shame, but he does enjoy sticks and tennis balls.", 30), 
	(Hint.new("Remember, you can pick stuff up by pressing Space or Shift.", 45) if not GLOBAL_STATE.is_single_player
		else Hint.new("Remember, you can pick stuff up by using Space and switch between players by pressing Shift.", 45)), 
	Hint.new("The dog will follow you if you are holding something he loves.", 75), 
	Hint.new("There are two sticks lying on the path. Can you spot them?", 105), 
	Hint.new("Try passing him one at a time.", 135), 
	Hint.new("There is no shame in clicking the \"I give up!\"-button, you know.", 210)],
    # fallen-tree
    [Hint.new("Uh-oh. Looks like yesterday's storm put some unmovable obstacle in your way.", 15), 
	Hint.new("Pressing Space and Shift might be useful.", 30), 
	Hint.new("Not everyone's legs are long enough to get over this tree, and that's alright.", 45), 
	Hint.new("Sometimes you just need to ask your stronger partner to help you in times of need.", 60), 
	Hint.new("There is also no shame in clicking the \"I give up!\"-button, you know.", 120)],
    # camping
    [Hint.new("Almost there! Just walk into the campsite together, and you can get some well deserved rest!", 15)]
]


onready var areas = get_children()
var players_in_area = []
var current_area = -1


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
