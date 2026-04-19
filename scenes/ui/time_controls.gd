extends HBoxContainer

@onready var pause_btn: Button = $PauseBtn
@onready var play_btn: Button = $PlayBtn
@onready var fast_btn: Button = $FastBtn
@onready var faster_btn: Button = $FasterBtn
@onready var fastest_btn: Button = $FastestBtn


func _ready() -> void:
	pause_btn.pressed.connect(func(): GameClock.set_time_scale(0.0))
	play_btn.pressed.connect(func(): GameClock.set_time_scale(1.0))
	fast_btn.pressed.connect(func(): GameClock.set_time_scale(2.0))
	faster_btn.pressed.connect(func(): GameClock.set_time_scale(4.0))
	fastest_btn.pressed.connect(func(): GameClock.set_time_scale(8.0))

	SignalBus.time_scale_changed.connect(_on_time_scale_changed)
	SignalBus.game_paused.connect(_on_game_paused)
	_update_buttons(1.0)


func _on_time_scale_changed(new_scale: float) -> void:
	_update_buttons(new_scale)


func _on_game_paused(is_paused: bool) -> void:
	if is_paused:
		_update_buttons(0.0)


func _update_buttons(scale: float) -> void:
	pause_btn.disabled = (scale == 0.0)
	play_btn.disabled = (scale == 1.0)
	fast_btn.disabled = (scale == 2.0)
	faster_btn.disabled = (scale == 4.0)
	fastest_btn.disabled = (scale == 8.0)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameClock.toggle_pause()
