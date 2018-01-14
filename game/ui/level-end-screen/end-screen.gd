extends PopupDialog

var MISSING_MESSAGES = {
	INVENTORY.NACHOS: "You'll be thinking about those missing nachos during the whole movie!",
	INVENTORY.TICKETS: "You forgot the tickets!\nBut, never mind, they were for the wrong day anyway.\n(True story.)",
	INVENTORY.SHAVER: "Stijn, you unshaved hobo!\nYou're lucky that Myrjam loves you just the way you are!",
	INVENTORY.DRESS: "Myrjam, are you going an a first date in your hiking clothes?!"
}
var NEEDED_ITEMS = MISSING_MESSAGES.keys()

onready var title = get_node("title")
onready var text = get_node("text")
onready var inventory = get_node("inventory")
onready var animation_player = get_node("animation-player")

func show(in_time):
	if in_time:
		title.set_text("Sweet!")
		text.set_text("You made it in time!\n" + missing_item_message())
	else:
		title.set_text("Oh, noes!")
		text.set_text("You didn't make it in time...\nLuckily, love conquers all!")
	inventory.refresh()
	popup()
	# This needs to happen because popup() puts it immediately on the screen
	set_pos(Vector2(460, -800))
	animation_player.play("drop-down")

func missing_item_message():
	var item = INVENTORY.random_missing_item(NEEDED_ITEMS)
	return MISSING_MESSAGES[item]
