extends Node

enum ItemType {BLOON, NACHOS, TICKETS, CHOCOLATE_MILK, SHAVER, DRESS}

var items

func _ready():
	items = []
	for _ in range(ItemType.size()):
		items.append(false)

func add(item_type):
	items[item_type] = true

func clear():
	for i in range(ItemType.size()):
		items[i] = false