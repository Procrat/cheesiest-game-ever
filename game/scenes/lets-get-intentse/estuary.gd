extends Node2D


onready var parts = get_children()

var parts_disabled_per_rock = {}


func disable_part_because_of(collider, rock):
	collider.set_layer_mask(0)
	collider.set_collision_mask(0)
	if rock in parts_disabled_per_rock:
		parts_disabled_per_rock[rock].append(collider.get_parent())
	else:
		parts_disabled_per_rock[rock] = [collider.get_parent()]
	rock.connect("sunk", self, "reenable_parts_from_rock", [rock])


func reenable_parts_from_rock(rock):
	if rock in parts_disabled_per_rock:
		var disabled_parts = parts_disabled_per_rock[rock]
		parts_disabled_per_rock.erase(rock)
		for part in disabled_parts:
			if part_in_map(part):
				continue
			var collider = part.get_node("collider")
			collider.set_layer_mask(1)
			collider.set_collision_mask(1)
			for body in part.get_overlapping_bodies():
				if body.is_in_group("players"):
					body.drown()


func part_in_map(part):
	for parts in parts_disabled_per_rock.values():
		if part in parts:
			return true
	return false
