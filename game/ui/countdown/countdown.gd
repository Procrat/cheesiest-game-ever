extends Label

signal timeout

var count

onready var when_to_count_down = get_node("when-to-count-down")
onready var when_to_stop = get_node("when-to-stop")

func _ready():
	when_to_count_down.connect("timeout", self, "count_down")
	when_to_stop.connect("timeout", self, "stop")
	count = int(when_to_stop.get_wait_time())
	update_text()

func count_down():
	count -= 1
	update_text()

func update_text():
	var text = "%d:%02d" % [int(count / 60), count % 60]
	set_text(text)

func stop():
	when_to_count_down.set_active(false)
	count = 0
	update_text()
	emit_signal("timeout")