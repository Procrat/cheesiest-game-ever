extends "res://game/ui/level-end-screen/end-screen.gd"

const Mischief = preload("res://game/scenes/mango-goes-bananas/mischief/mischief.gd")

const MISCHIEF_MESSAGES = {
	Mischief.MEAT: "But I guess you'll have to go to bed without dinner...",
	Mischief.FRIDGE: "However, the next day you realise that your breakfast is missing from the fridge.",
	Mischief.VOMIT: "But you'll be carrying that rug to the dry cleaner on your bike.",
	Mischief.PEE: "But you'll have to sleep on the floor tonight..."
}


func _init().(1):
	pass


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
	
	var has_won = drawn_enough && studied_enough && ignored_mischief.size() <= 0
	popup(has_won)


func ignored_mischief_message(ignored_mischief):
	var random_mischief = ignored_mischief[randi() % ignored_mischief.size()]
	return MISCHIEF_MESSAGES[random_mischief]
