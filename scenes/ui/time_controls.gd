extends HBoxContainer

@onready var pause_btn: Button = $PauseBtn
@onready var halve_btn: Button = $HalveBtn
@onready var speed_label: Label = $SpeedLabel
@onready var dobrar_btn: Button = $DobrarBtn


func _ready() -> void:
	pause_btn.pressed.connect(func(): GameClock.toggle_pause())
	halve_btn.pressed.connect(func(): GameClock.halve())
	dobrar_btn.pressed.connect(func(): GameClock.dobrar())

	SignalBus.time_scale_changed.connect(_on_time_scale_changed)
	SignalBus.game_paused.connect(_on_game_paused)
	_update_display(1.0)


func _on_time_scale_changed(new_scale: float) -> void:
	_update_display(new_scale)


func _on_game_paused(is_paused: bool) -> void:
	if is_paused:
		_update_display(0.0)


func _update_display(scale: float) -> void:
	if scale == 0.0:
		speed_label.text = "PAUSED"
		pause_btn.text = ">"
		pause_btn.tooltip_text = "Resume"
	else:
		speed_label.text = "%gx" % scale
		pause_btn.text = "||"
		pause_btn.tooltip_text = "Pause"
	halve_btn.disabled = (scale <= 1.0)
	dobrar_btn.disabled = (scale >= GameClock.MAX_TIME_SCALE)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		GameClock.toggle_pause()
