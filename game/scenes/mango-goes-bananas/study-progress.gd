extends AnimatedSprite

const utils = preload("res://game/utils.gd")

enum Player {MYRJAM, STIJN}
export(int, "Myrjam", "Stijn") var listening_to
export(int) var single_player_duration = 60
export(int) var multi_player_duration = 60


func _ready():
	var player_name = "Myrjam" if listening_to == MYRJAM else "Stijn"
	var emitter = get_node("/root/level/" + player_name)
	var duration = single_player_duration if GLOBAL_STATE.is_single_player else multi_player_duration
	utils.set_animation_duration(self, "default", duration)
	emitter.connect("started_working", self, "play")
	emitter.connect("stopped_working", self, "stop")


func has_done_enough():
	return get_frame() >= get_sprite_frames().get_frame_count(get_animation()) - 1
