extends Node2D

var STATE_NODE_NAMES = {
	INVENTORY.NOT_TAKEN: "shadow",
	INVENTORY.TAKEN_EARLIER: "regular",
	INVENTORY.JUST_TAKEN: "highlight"
}

onready var items = [
	get_node("bloon"),
	get_node("nachos"),
	get_node("tickets"),
	get_node("chocolate-milk"),
	get_node("shaver"),
	get_node("dress")
]

func refresh():
	var item_states = INVENTORY.age_items()
	for item in range(item_states.size()):
		for state_node in items[item].get_children():
			state_node.hide()
		var state = item_states[item]
		var state_node_name = STATE_NODE_NAMES[state]
		var state_node = items[item].get_node(state_node_name)
		state_node.show()
