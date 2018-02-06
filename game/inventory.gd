extends Node

enum ItemType {BLOON, NACHOS, TICKETS, CHOCOLATE_MILK, SHAVER, DRESS}
enum ItemState {NOT_TAKEN, TAKEN_EARLIER, JUST_TAKEN}

var items

func _ready():
	items = []
	for _ in range(ItemType.size()):
		items.append(NOT_TAKEN)
	randomize()

func add(item_type):
	items[item_type] = JUST_TAKEN
	if item_type in [NACHOS, CHOCOLATE_MILK]:
		SFX.play("nom")

func clear():
	for i in range(ItemType.size()):
		items[i] = NOT_TAKEN

func age_items():
	var old_items = [] + items
	for item_type in range(ItemType.size()):
		if items[item_type] == JUST_TAKEN:
			items[item_type] = TAKEN_EARLIER
	return old_items

func has_got_everything(needed):
	for item_type in needed:
		if items[item_type] == NOT_TAKEN:
			return false
	return true

func random_missing_item(needed):
	var missing = []
	for item_type in needed:
		if items[item_type] == NOT_TAKEN:
			missing.append(item_type)
	return missing[randi() % missing.size()]
