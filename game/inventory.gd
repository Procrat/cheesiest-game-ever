extends Node

enum ItemType {BLOON, NACHOS, TICKETS, CHOCOLATE_MILK, SHAVER, DRESS}

var items

func _ready():
	items = []
	for _ in range(ItemType.size()):
		items.append(false)
	randomize()

func add(item_type):
	items[item_type] = true

func clear():
	for i in range(ItemType.size()):
		items[i] = false

func random_missing_item(needed):
	var missing = []
	for item_type in needed:
		if not item_type in items:
			missing.append(item_type)
	return missing[randi() % missing.size()]
