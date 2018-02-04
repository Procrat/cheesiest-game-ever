extends "res://game/scenes/lets-get-intentse/pickable.gd"

signal sunk

var SINKING_TIME = 4

var initialised = false
var original_location
var fade_away_timer

onready var animations = get_node("animations")
onready var particles = get_node("particles")

var stuck = false


func _init():
	if not initialised:
		original_location = get_pos()
		connect("body_enter", self, "body_enter")


func _ready():
	setup(Vector2(0, 0), Vector2(0, -30), 5.0 / 24.0, 3.0 / 24.0, Vector2(30, 20))
	var sprite_frames = animations.get_sprite_frames()
	sprite_frames.set_animation_speed("sinking", sprite_frames.get_frame_count("sinking") / SINKING_TIME)


func be_picked_up_by(player):
	if not stuck and .be_picked_up_by(player):
		if fade_away_timer != null:
			fade_away_timer.cancel()
		return true
	return false


func be_dropped():
	if .be_dropped():
		fade_away_timer = utils.do_once_after(SINKING_TIME, self, self, "fade_away")
		return true
	return false


func body_enter(body):
	if not picked_up and body.is_in_group("estuary"):
		if not stuck:
			animations.play("sinking")
			particles.set_emitting(true)
		stuck = true
		body.get_parent().get_parent().disable_part_because_of(body, self)


func fade_away():
	set_pos(original_location)
	animations.play("rock")
	particles.set_emitting(false)
	particles.reset()
	stuck = false
	emit_signal("sunk")
