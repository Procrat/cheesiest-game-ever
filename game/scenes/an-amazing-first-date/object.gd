extends Area2D

export(int, "Bloon", "Nachos", "Tickets", "Chocolate milk", "Shaver", "Dress") var item_type

func _ready():
	connect("body_enter", self, "collide")

func collide(body):
	if body.is_in_group("players"):
		be_picked_up()

func be_picked_up():
	INVENTORY.add(item_type)
	set_hidden(true)