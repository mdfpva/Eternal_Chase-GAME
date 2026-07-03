extends Area2D

const SPEED := 600.0

var direction := 1
var lifetime := 2.0

func _ready() -> void:
	$Sprite2D.modulate = Palette.get_color("bullet")

func _process(delta: float) -> void:
	position.x += direction * SPEED * delta
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
