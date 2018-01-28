extends "res://game/scenes/lets-get-intentse/pickable.gd"

var SINKING_TIME = 4

var initialised = false
var original_location
var fade_away_timer

onready var animations = get_node("animations")

var estuary_parts_disabled = []
var stuck = false


func _init():
	if not initialised:
		original_location = get_pos()
		fade_away_timer = Timer.new()
		fade_away_timer.set_wait_time(SINKING_TIME)
		fade_away_timer.set_one_shot(true)
		fade_away_timer.connect("timeout", self, "fade_away")
		add_child(fade_away_timer)
	
		connect("body_enter", self, "body_enter")


func _ready():
	setup(Vector2(30, 0))


func be_picked_up_by(player):
	if not stuck and .be_picked_up_by(player):
		fade_away_timer.stop()
		return true
	return false


func be_dropped():
	if .be_dropped():
		fade_away_timer.start()
		return true
	return false


func body_enter(body):
	if not picked_up and body.is_in_group("estuary"):
		if not stuck:
			var sprite_frames = animations.get_sprite_frames()
			sprite_frames.set_animation_speed("sinking", sprite_frames.get_frame_count("sinking") / SINKING_TIME)
			animations.play("sinking")
		stuck = true
		disable_estuary(body)


func disable_estuary(estuary):
	estuary.set_layer_mask(0)
	estuary.set_collision_mask(0)
	estuary_parts_disabled.append(estuary)


func reenable_estuary():
	var respawned = false
	for estuary in estuary_parts_disabled:
		estuary.set_layer_mask(1)
		estuary.set_collision_mask(1)
		# Update kinematic physics
		estuary.move(Vector2(0, 0))
		if not respawned and estuary.is_colliding():
			var possibly_the_player = estuary.get_collider()
			if possibly_the_player.is_in_group("players"):
				possibly_the_player.respawn()
				respawned = true
	estuary_parts_disabled.clear()


func fade_away():
	set_pos(original_location)
	reenable_estuary()
	animations.play("rock")
	stuck = false
