extends Node

enum Difficulty { EASY, NORMAL, HARD }

var difficulty: Difficulty = Difficulty.NORMAL

signal difficulty_changed(new_difficulty: Difficulty)


## Returns a bonus added to skill rolls based on difficulty.
func get_difficulty_bonus() -> int:
	match difficulty:
		Difficulty.EASY: return 2
		Difficulty.NORMAL: return 0
		Difficulty.HARD: return -1
	return 0


func set_difficulty(new_difficulty: Difficulty) -> void:
	difficulty = new_difficulty
	difficulty_changed.emit(new_difficulty)


func get_difficulty_name() -> String:
	match difficulty:
		Difficulty.EASY: return "Easy"
		Difficulty.NORMAL: return "Normal"
		Difficulty.HARD: return "Hard"
	return "Normal"
