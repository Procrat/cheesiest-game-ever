extends PopupDialog

var Mischief = preload("res://game/scenes/mango-goes-bananas/mischief/mischief.gd")

var MISCHIEF_MESSAGES = {
	Mischief.MEAT: "But I guess you'll have to go to bed without dinner...",
	Mischief.FRIDGE: "However, the next day you realise that your breakfast is missing from the fridge.",
	Mischief.VOMIT: "But you'll be carrying that rug to the dry cleaner on your bike."
}

onready var title = get_node("title")
onready var subtitle = get_node("subtitle")
onready var text = get_node("text")
onready var inventory = get_node("inventory")
onready var retry_button = get_node("retry-button")
onready var animation_player = get_node("animation-player")

func show(ignored_mischief, drawn_enough, studied_enough):
	if not drawn_enough:
		title.set_text("Argh!")
		subtitle.set_text("You'll never make a living with drawing like this!")
		text.set_text("")
	elif not studied_enough:
		title.set_text("Argh!")
		subtitle.set_text("You'll have to redo that exam of tomorrow!")
		text.set_text("")
	elif ignored_mischief.size() <= 0:
		title.set_text("Hooray!")
		subtitle.set_text("")
		text.set_text("You managed to draw and study enough while keeping the monster at bay!")
		retry_button.hide()
	else:
		# Say something about random mischief that was ignored
		title.set_text("Argh!")
		subtitle.set_text("")
		text.set_text("You managed to study enough...\n" + ignored_mischief_message(ignored_mischief))
	
	inventory.hide()
	
	popup()
	# HACK: This needs to happen because popup() puts it immediately on the screen
	set_pos(Vector2(425, -800))
	animation_player.play("drop-down")

func ignored_mischief_message(ignored_mischief):
	var random_mischief = ignored_mischief[randi() % ignored_mischief.size()]
	return MISCHIEF_MESSAGES[random_mischief]
