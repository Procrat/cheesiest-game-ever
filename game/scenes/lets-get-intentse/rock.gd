extends "res://game/scenes/lets-get-intentse/pickable.gd"

signal sunk

var SINKING_TIME = 4

var initialised = false
var original_location
var fade_away_timer

onready var animations = get_node("animations")

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
	setup(Vector2(30, 20))


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
		body.get_parent().get_parent().disable_part_because_of(body, self)


func fade_away():
	set_pos(original_location)
	animations.play("rock")
	stuck = false
	emit_signal("sunk")
