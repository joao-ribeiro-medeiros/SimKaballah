extends PanelContainer

@onready var triangle_display: Control = %TriangleDisplay
@onready var creation_bar: ProgressBar = %CreationBar
@onready var destruction_bar: ProgressBar = %DestructionBar
@onready var conservation_bar: ProgressBar = %ConservationBar
@onready var status_label: Label = %StatusLabel
@onready var creation_label: Label = %CreationLabel
@onready var destruction_label: Label = %DestructionLabel
@onready var conservation_label: Label = %ConservationLabel


func _ready() -> void:
	SignalBus.cosmic_shift.connect(_on_cosmic_shift)
	SignalBus.cosmic_crisis_resolved.connect(_on_crisis_resolved)
	_refresh()


func _refresh() -> void:
	var state := CosmicBalance.get_state()
	_update_bars(state.creation, state.destruction, state.conservation)
	_update_status()
	if triangle_display:
		triangle_display.queue_redraw()


func _on_cosmic_shift(creation: float, destruction: float, conservation: float) -> void:
	_update_bars(creation, destruction, conservation)
	_update_status()
	if triangle_display:
		triangle_display.queue_redraw()


func _update_bars(creation: float, destruction: float, conservation: float) -> void:
	creation_bar.value = creation * 100
	destruction_bar.value = destruction * 100
	conservation_bar.value = conservation * 100
	creation_label.text = "Creation: %.1f%%" % (creation * 100)
	destruction_label.text = "Destruction: %.1f%%" % (destruction * 100)
	conservation_label.text = "Conservation: %.1f%%" % (conservation * 100)


func _update_status() -> void:
	if CosmicBalance.is_in_crisis():
		var dominant := CosmicBalance.get_dominant()
		var tendency_name: String = Enums.CosmicTendency.keys()[dominant]
		status_label.text = "CRISIS: %s Dominant!" % tendency_name.capitalize()
		status_label.modulate = Color.RED
	else:
		var imbalance := CosmicBalance.get_state().get_imbalance()
		if imbalance < 0.1:
			status_label.text = "Balanced"
			status_label.modulate = Color.GREEN
		else:
			status_label.text = "Drifting..."
			status_label.modulate = Color.YELLOW


func _on_crisis_resolved() -> void:
	status_label.text = "Crisis Resolved!"
	status_label.modulate = Color.GREEN
	_refresh()
