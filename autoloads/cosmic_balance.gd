extends Node

var state: CosmicState = CosmicState.new()

const DRIFT_RATE := 0.001
var _drift_target: Enums.CosmicTendency = Enums.CosmicTendency.CREATION


func _ready() -> void:
	_randomize_drift_target()


func tick() -> void:
	_apply_drift()
	SignalBus.cosmic_shift.emit(state.creation, state.destruction, state.conservation)


func _apply_drift() -> void:
	match _drift_target:
		Enums.CosmicTendency.CREATION:
			state.creation += DRIFT_RATE
		Enums.CosmicTendency.DESTRUCTION:
			state.destruction += DRIFT_RATE
		Enums.CosmicTendency.CONSERVATION:
			state.conservation += DRIFT_RATE
	state.normalize()
	# Occasionally change drift target
	if randf() < 0.05:
		_randomize_drift_target()


func _randomize_drift_target() -> void:
	_drift_target = [
		Enums.CosmicTendency.CREATION,
		Enums.CosmicTendency.DESTRUCTION,
		Enums.CosmicTendency.CONSERVATION
	].pick_random()


func apply_shift(shift: Dictionary) -> void:
	state.apply_shift(shift)
	SignalBus.cosmic_shift.emit(state.creation, state.destruction, state.conservation)


func is_in_crisis() -> bool:
	return state.is_in_crisis()


func get_dominant() -> Enums.CosmicTendency:
	return state.get_dominant()


func resolve_crisis() -> void:
	state.reset_balance()
	SignalBus.cosmic_crisis_resolved.emit()
	SignalBus.cosmic_shift.emit(state.creation, state.destruction, state.conservation)


## Returns encounter spawn rate multiplier based on cosmic state.
func get_spawn_rate_modifier() -> float:
	if not is_in_crisis():
		return 1.0
	match get_dominant():
		Enums.CosmicTendency.CREATION:
			return 1.5
		Enums.CosmicTendency.CONSERVATION:
			return 0.5
		_:
			return 1.0


## Returns XP modifier based on cosmic state.
func get_xp_modifier() -> float:
	if is_in_crisis() and get_dominant() == Enums.CosmicTendency.CONSERVATION:
		return 0.5
	return 1.0


func get_state() -> CosmicState:
	return state


func load_state(loaded: CosmicState) -> void:
	state = loaded
