extends PopupDialog

const LevelSelectScene = preload("res://game/scenes/level-select/level-select.tscn")

onready var title = get_node("title")
onready var subtitle = get_node("subtitle")
onready var text = get_node("text")
onready var inventory = get_node("inventory")
onready var retry_button = get_node("retry-button")
onready var next_button = get_node("next-button")
onready var animation_player = get_node("animation-player")

var level


func _init(level):
	self.level = level


func _ready():
	retry_button.connect("pressed", self, "restart")
	next_button.connect("pressed", self, "go_to_next_level")


func popup(has_won):
	get_tree().set_pause(true)
	if has_won:
		retry_button.set_text("Play again")
	.popup()
	# HACK: This needs to happen because popup() puts it immediately on the screen
	set_pos(Vector2(425, -800))
	animation_player.play("drop-down")


func restart():
	get_tree().reload_current_scene()
	get_tree().set_pause(false)


func go_to_next_level():
	GLOBAL_STATE.ensure_level_unlocked(level + 1)
	get_tree().change_scene_to(LevelSelectScene)
	get_tree().set_pause(false)
