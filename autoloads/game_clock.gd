extends Node

const BASE_GAME_SPEED := 180.0 # 1 real second = 3 game minutes at 1x
const TICK_INTERVAL_MINUTES := 5.0 # system tick every 5 game minutes
const MAX_TIME_SCALE := 128.0

var time_scale: float = 1.0
var elapsed_game_minutes: float = 0.0
var _tick_accumulator: float = 0.0
var _is_paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if _is_paused:
		return

	var game_delta := delta * time_scale * BASE_GAME_SPEED
	if game_delta <= 0.0:
		return

	elapsed_game_minutes += game_delta / 60.0

	SignalBus.time_tick.emit(game_delta)

	_tick_accumulator += game_delta
	if _tick_accumulator >= TICK_INTERVAL_MINUTES * 60.0:
		_tick_accumulator -= TICK_INTERVAL_MINUTES * 60.0
		_on_system_tick()


func _on_system_tick() -> void:
	EncounterManager.tick()
	CosmicBalance.tick()


func set_time_scale(new_scale: float) -> void:
	time_scale = new_scale
	if new_scale == 0.0:
		pause_game()
	elif _is_paused:
		unpause_game()
	SignalBus.time_scale_changed.emit(new_scale)


func dobrar() -> void:
	if _is_paused:
		unpause_game()
		return
	var new_scale := minf(time_scale * 2.0, MAX_TIME_SCALE)
	set_time_scale(new_scale)


func halve() -> void:
	var new_scale := maxf(time_scale / 2.0, 1.0)
	set_time_scale(new_scale)


func pause_game() -> void:
	_is_paused = true
	time_scale = 0.0
	SignalBus.game_paused.emit(true)


func unpause_game() -> void:
	_is_paused = false
	if time_scale == 0.0:
		time_scale = 1.0
	SignalBus.game_paused.emit(false)


func toggle_pause() -> void:
	if _is_paused:
		unpause_game()
	else:
		pause_game()


func is_paused() -> bool:
	return _is_paused


func get_game_hours() -> float:
	return elapsed_game_minutes / 60.0


func get_game_days() -> float:
	return elapsed_game_minutes / 1440.0


func get_time_string() -> String:
	var total_minutes := int(elapsed_game_minutes)
	var days := total_minutes / 1440
	var hours := (total_minutes % 1440) / 60
	var minutes := total_minutes % 60
	return "Day %d, %02d:%02d" % [days + 1, hours, minutes]
