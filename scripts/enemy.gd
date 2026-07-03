extends Area2D

@export var patrol_distance := 100.0
@export var speed := 80.0

var start_x := 0.0
var direction := 1

func _ready() -> void:
	start_x = position.x
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	_update_color()
	Palette.palette_changed.connect(_update_color)

func _update_color() -> void:
	$Sprite2D.modulate = Palette.get_color("enemy")

func _process(delta: float) -> void:
	position.x += direction * speed * delta
	if absf(position.x - start_x) > patrol_distance:
		direction *= -1

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Game.die()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("bullet"):
		area.queue_free()
		Game.add_kill()
		queue_free()
