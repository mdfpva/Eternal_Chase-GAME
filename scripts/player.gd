extends CharacterBody2D

const SPEED := 300.0
const JUMP_VELOCITY := -540.0
const COYOTE_TIME := 0.12
const BULLET_SCENE := preload("res://scenes/Bullet.tscn")

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var coyote_timer := 0.0

func _ready() -> void:
	add_to_group("player")
	_update_color()
	Palette.palette_changed.connect(_update_color)

func _update_color() -> void:
	$Sprite2D.modulate = Palette.get_color("player")

func _unhandled_input(event: InputEvent) -> void:
	if Game.game_over:
		return
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_X:
		shoot()

func shoot() -> void:
	var bullet: Area2D = BULLET_SCENE.instantiate()
	var facing := 1 if $Sprite2D.scale.x > 0 else -1
	bullet.direction = facing
	bullet.global_position = global_position + Vector2(facing * 24, 0)
	get_tree().current_scene.add_child(bullet)

func _physics_process(delta: float) -> void:
	if Game.game_over:
		return

	if is_on_floor():
		coyote_timer = COYOTE_TIME
	else:
		velocity.y += gravity * delta
		coyote_timer -= delta

	if coyote_timer > 0.0 and Input.is_action_just_pressed("ui_accept"):
		velocity.y = JUMP_VELOCITY
		coyote_timer = 0.0

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * SPEED
		$Sprite2D.scale.x = 2 if direction > 0 else -2
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

	Game.update_distance(global_position.x)

	if global_position.y > 900:
		Game.die()
