extends Area2D

@export var location_id: String = ""
@export var location_name: String = ""
@export var connected_locations: Array[String] = []

@onready var label: Label = $Label
@onready var icon: Sprite2D = $Icon
@onready var encounter_glow: AnimationPlayer = $EncounterGlow

var _has_encounter: bool = false
var _is_hovered: bool = false


func _ready() -> void:
	label.text = location_name
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		SignalBus.location_clicked.emit(location_id)


func _on_mouse_entered() -> void:
	_is_hovered = true
	modulate = Color(1.3, 1.3, 1.3)


func _on_mouse_exited() -> void:
	_is_hovered = false
	modulate = Color.WHITE


func get_location_data() -> Dictionary:
	return {
		"id": location_id,
		"name": location_name,
		"position": global_position,
		"connections": connected_locations,
	}


func show_encounter_marker(show: bool) -> void:
	_has_encounter = show
	if encounter_glow:
		if show:
			encounter_glow.play("glow")
		else:
			encounter_glow.stop()
