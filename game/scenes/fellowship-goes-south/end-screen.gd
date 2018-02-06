extends "res://game/ui/level-end-screen/end-screen.gd"

const MISSING_MESSAGES = [
    "Let's hope you still find those passports at some point.",
    "This isn't the first time you forgot those tent pegs, is it?",
    "I guess they sell power adapters in New Zealand as well.",
    "What are you going to do in New Zealand if you're not taking your hiking shoes?"
]

func _init().(2):
	pass


func show(all_objects_found, objects_found):
	if all_objects_found:
		title.set_text("Sweet as!")
		subtitle.set_text("")
		text.set_text("Now you're ready to go on a new adventure!")
	else:
		title.set_text("Buggers!")
		subtitle.set_text("")
		text.set_text(first_missing_object_message(objects_found))
	
	inventory.hide()
	
	popup(all_objects_found)


func first_missing_object_message(objects_found):
	for i in range(objects_found.size()):
		if not objects_found[i]:
			return MISSING_MESSAGES[i]
