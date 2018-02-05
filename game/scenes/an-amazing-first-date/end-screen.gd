extends PopupDialog

var MISSING_MESSAGES = {
	INVENTORY.NACHOS: "You'll be thinking about those missing nachos during the whole movie!",
	INVENTORY.TICKETS: "You forgot the tickets!\nBut, never mind, they were for the wrong day anyway.\n(True story.)",
	INVENTORY.SHAVER: "Stijn, you unshaved hobo!\nYou're lucky that Myrjam loves you just the way you are!",
	INVENTORY.DRESS: "Myrjam, are you going an a first date in your hiking clothes?!"
}
var NEEDED_ITEMS = MISSING_MESSAGES.keys()

onready var title = get_node("title")
onready var subtitle = get_node("subtitle")
onready var text = get_node("text")
onready var inventory = get_node("inventory")
onready var retry_button = get_node("retry-button")
onready var animation_player = get_node("animation-player")

func show(in_time):
	if in_time:
		title.set_text("Sweet!")
		subtitle.set_text("You made it in time!")
		if INVENTORY.has_got_everything(NEEDED_ITEMS):
			text.set_text("Wow, you also managed to make this date absolutely perfect.")
			retry_button.hide()
		else:
			text.set_text(missing_item_message())
	else:
		title.set_text("Oh, noes!")
		subtitle.set_text("You didn't make it in time...\nLuckily, love conquers all!")
	inventory.refresh()
	popup()
	# HACK: This needs to happen because popup() puts it immediately on the screen
	set_pos(Vector2(425, -800))
	animation_player.play("drop-down")

func missing_item_message():
	var item = INVENTORY.random_missing_item(NEEDED_ITEMS)
	return MISSING_MESSAGES[item]
