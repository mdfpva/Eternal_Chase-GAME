extends Node

# Okabe-Ito colorblind-safe palette (distinguishable under protanopia,
# deuteranopia and tritanopia): https://jfly.uni-koeln.de/color/
const SAFE_COLORS := [
	Color(0.902, 0.624, 0.0),   # orange
	Color(0.337, 0.706, 0.914), # sky blue
	Color(0.0, 0.620, 0.451),   # bluish green
	Color(0.941, 0.894, 0.259), # yellow
	Color(0.0, 0.447, 0.698),   # blue
	Color(0.835, 0.369, 0.0),   # vermillion
	Color(0.800, 0.475, 0.655), # reddish purple
]

const ROLES := ["player", "ground", "platform", "moving_platform", "enemy", "coin", "bullet"]
const SHUFFLE_INTERVAL := 18.0

signal palette_changed

var current: Dictionary = {}
var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()
	_shuffle()
	var timer := Timer.new()
	timer.wait_time = SHUFFLE_INTERVAL
	timer.autostart = true
	timer.timeout.connect(_shuffle)
	add_child(timer)

func get_color(role: String) -> Color:
	return current.get(role, Color.WHITE)

func _shuffle() -> void:
	var colors := SAFE_COLORS.duplicate()
	colors.shuffle()
	for i in range(ROLES.size()):
		current[ROLES[i]] = colors[i]
	palette_changed.emit()
