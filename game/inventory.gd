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

func clear():
	for i in range(ItemType.size()):
		items[i] = NOT_TAKEN

func age_items():
	var old_items = [] + items
	for item_type in range(ItemType.size()):
		print("old", old_items)
		print("new", items)
		if items[item_type] == JUST_TAKEN:
			items[item_type] = TAKEN_EARLIER
	print("old", old_items)
	print("new", items)
	return old_items

func random_missing_item(needed):
	var missing = []
	for item_type in needed:
		if items[item_type] == NOT_TAKEN:
			missing.append(item_type)
	return missing[randi() % missing.size()]
