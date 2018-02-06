extends CollisionObject2D

export(String, MULTILINE) var text

const utils = preload("res://game/utils.gd")
const TextFx = preload("res://game/ui/text-fx.tscn")


func _input_event(viewport, event, shape_idx):
	if event.is_pressed():
		var text_fx = TextFx.instance()
		add_child(text_fx)
		text_fx.get_node("label").set_text(text)
		text_fx.get_node("player").play("popup")
		utils.do_once_after_animation(text_fx.get_node("player"), text_fx, "queue_free")