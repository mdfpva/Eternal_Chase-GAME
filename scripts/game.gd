extends Node

signal stats_changed
signal died
signal new_highscore_reached

const START_X := 100.0
const SAVE_PATH := "user://scores.json"
const MAX_SCORES := 5

var distance := 0
var coins := 0
var kills := 0
var game_over := false
var scores: Array = []
var is_new_highscore := false
var previous_best := 0
var beaten_highscore_live := false

func _ready() -> void:
	_load_scores()

func add_coin() -> void:
	coins += 1
	stats_changed.emit()

func add_kill() -> void:
	kills += 1
	stats_changed.emit()

func update_distance(player_x: float) -> void:
	var d := int(max(0.0, player_x - START_X) / 10.0)
	if d > distance:
		distance = d
		stats_changed.emit()
		if not beaten_highscore_live and previous_best > 0 and distance > previous_best:
			beaten_highscore_live = true
			new_highscore_reached.emit()

func die() -> void:
	if game_over:
		return
	game_over = true
	_record_score()
	died.emit()

func reset() -> void:
	distance = 0
	coins = 0
	kills = 0
	game_over = false
	is_new_highscore = false
	previous_best = get_highscore()
	beaten_highscore_live = false

func clear_scores() -> void:
	scores.clear()
	is_new_highscore = false
	previous_best = 0
	_save_scores()

func get_highscore() -> int:
	if scores.is_empty():
		return 0
	return scores[0].get("distance", 0)

func _record_score() -> void:
	is_new_highscore = distance > 0 and distance > previous_best
	scores.append({"distance": distance, "coins": coins, "kills": kills})
	scores.sort_custom(func(a, b): return a["distance"] > b["distance"])
	if scores.size() > MAX_SCORES:
		scores.resize(MAX_SCORES)
	_save_scores()

func _save_scores() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(scores))
		file.close()

func _load_scores() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed is Array:
		scores = parsed
