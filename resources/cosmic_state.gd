class_name CosmicState
extends Resource

@export var creation: float = 0.333
@export var destruction: float = 0.333
@export var conservation: float = 0.334

const CRISIS_THRESHOLD := 0.6


func normalize() -> void:
	var total := creation + destruction + conservation
	if total <= 0.0:
		creation = 0.333
		destruction = 0.333
		conservation = 0.334
		return
	creation /= total
	destruction /= total
	conservation /= total


func apply_shift(shift: Dictionary) -> void:
	creation += shift.get("creation", 0.0)
	destruction += shift.get("destruction", 0.0)
	conservation += shift.get("conservation", 0.0)
	# Clamp negatives
	creation = maxf(creation, 0.0)
	destruction = maxf(destruction, 0.0)
	conservation = maxf(conservation, 0.0)
	normalize()


func is_in_crisis() -> bool:
	return creation > CRISIS_THRESHOLD or destruction > CRISIS_THRESHOLD or conservation > CRISIS_THRESHOLD


func get_dominant() -> Enums.CosmicTendency:
	if creation >= destruction and creation >= conservation:
		return Enums.CosmicTendency.CREATION
	elif destruction >= creation and destruction >= conservation:
		return Enums.CosmicTendency.DESTRUCTION
	else:
		return Enums.CosmicTendency.CONSERVATION


func get_imbalance() -> float:
	# 0.0 = perfect balance, 1.0 = maximum imbalance
	var ideal := 1.0 / 3.0
	var diff := absf(creation - ideal) + absf(destruction - ideal) + absf(conservation - ideal)
	return diff / (4.0 / 3.0) # normalize to 0-1 range


func reset_balance() -> void:
	creation = 0.333
	destruction = 0.333
	conservation = 0.334
