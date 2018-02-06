extends "res://game/ui/level-end-screen/end-screen.gd"

var MISSING_MESSAGES = {
	INVENTORY.NACHOS: "You'll be thinking about those missing nachos during the whole movie!",
	INVENTORY.TICKETS: "You forgot the tickets!\nBut, never mind, they were for the wrong day anyway.\n(True story.)",
	INVENTORY.SHAVER: "Stijn, you unshaved hobo!\nYou're lucky that Myrjam loves you just the way you are!",
	INVENTORY.DRESS: "Myrjam, are you going an a first date in your hiking clothes?!"
}
var NEEDED_ITEMS = MISSING_MESSAGES.keys()


func _init().(0):
	pass


func show(in_time):
	var has_won = false
	if in_time:
		title.set_text("Sweet!")
		subtitle.set_text("You made it in time!")
		if INVENTORY.has_got_everything(NEEDED_ITEMS):
			has_won = true
			text.set_text("Wow, you also managed to make this date absolutely perfect.")
			retry_button.hide()
		else:
			text.set_text(missing_item_message())
	else:
		title.set_text("Oh, noes!")
		subtitle.set_text("You didn't make it in time...\nLuckily, love conquers all!")
	
	inventory.refresh()
	
	popup(has_won)


func missing_item_message():
	var item = INVENTORY.random_missing_item(NEEDED_ITEMS)
	return MISSING_MESSAGES[item]
