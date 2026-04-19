extends PanelContainer

@onready var time_label: Label = %TimeLabel
@onready var location_label: Label = %LocationLabel
@onready var cosmic_container: VBoxContainer = %CosmicContainer
@onready var creation_bar: ProgressBar = %CreationBar
@onready var destruction_bar: ProgressBar = %DestructionBar
@onready var conservation_bar: ProgressBar = %ConservationBar
@onready var creation_pct: Label = %CreationPct
@onready var destruction_pct: Label = %DestructionPct
@onready var conservation_pct: Label = %ConservationPct
@onready var alert_label: Label = %AlertLabel


func _ready() -> void:
	SignalBus.time_tick.connect(_on_time_tick)
	SignalBus.cosmic_shift.connect(_on_cosmic_shift)
	SignalBus.party_arrived.connect(_on_party_arrived)
	SignalBus.encounter_spawned.connect(_on_encounter_spawned)
	alert_label.text = ""


func _on_time_tick(_delta: float) -> void:
	var scale_text: String
	if GameClock.time_scale == 0.0:
		scale_text = "PAUSED"
	else:
		scale_text = "%gx" % GameClock.time_scale
	time_label.text = "%s [%s]" % [GameClock.get_time_string(), scale_text]


func _on_cosmic_shift(creation: float, destruction: float, conservation: float) -> void:
	creation_bar.value = creation * 100
	destruction_bar.value = destruction * 100
	conservation_bar.value = conservation * 100
	creation_pct.text = "%d%%" % int(creation * 100)
	destruction_pct.text = "%d%%" % int(destruction * 100)
	conservation_pct.text = "%d%%" % int(conservation * 100)

	if CosmicBalance.is_in_crisis():
		alert_label.text = "COSMIC CRISIS!"
		alert_label.modulate = Color.RED
	else:
		alert_label.text = ""


func _on_party_arrived(location_id: String) -> void:
	location_label.text = location_id.capitalize()


func _on_encounter_spawned(_enc_def, location_id: String) -> void:
	if location_id == PartyManager.current_location:
		_flash_alert("Encounter at %s!" % location_id.capitalize())


func _flash_alert(text: String) -> void:
	alert_label.text = text
	alert_label.modulate = Color.YELLOW
	var tween := create_tween()
	tween.tween_property(alert_label, "modulate:a", 0.0, 3.0)
