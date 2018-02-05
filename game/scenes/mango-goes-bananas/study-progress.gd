extends AnimatedSprite

enum Player {MYRJAM, STIJN}
export(int, "Myrjam", "Stijn") var listening_to


func _ready():
	var player_name = "Myrjam" if listening_to == MYRJAM else "Stijn"
	var emitter = get_node("/root/level/" + player_name)
	emitter.connect("started_working", self, "play")
	emitter.connect("stopped_working", self, "stop")


func has_done_enough():
	return get_frame() >= get_sprite_frames().get_frame_count(get_animation()) - 1
