extends Area2D

@export var location_id: String = ""
@export var location_name: String = ""
@export var connected_locations: Array[String] = []

@onready var label: Label = $Label
@onready var dot: Polygon2D = $Dot
@onready var encounter_ring: Polygon2D = $EncounterRing

var _has_encounter: bool = false
var _is_hovered: bool = false
var _encounter_tween: Tween = null


func _ready() -> void:
	label.text = location_name
	input_event.connect(_on_input_event)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	if encounter_ring:
		encounter_ring.hide()


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
		"position": position,
		"connections": connected_locations,
	}


func show_encounter_marker(show_it: bool) -> void:
	_has_encounter = show_it
	if _encounter_tween:
		_encounter_tween.kill()
		_encounter_tween = null

	if show_it:
		if encounter_ring:
			encounter_ring.show()
		# Tween-based pulsing: red/orange color oscillation on Dot
		_start_pulse()
	else:
		if encounter_ring:
			encounter_ring.hide()
		if dot:
			dot.color = Color(1, 0.85, 0.4, 0.9) # restore original


func set_highlight(on: bool) -> void:
	if on:
		modulate = Color(1.4, 1.3, 0.8)
	else:
		if _is_hovered:
			modulate = Color(1.3, 1.3, 1.3)
		else:
			modulate = Color.WHITE


func _start_pulse() -> void:
	if dot == null:
		return
	_encounter_tween = create_tween().set_loops()
	_encounter_tween.tween_property(dot, "color", Color(1.0, 0.2, 0.1, 1.0), 0.5)
	_encounter_tween.tween_property(dot, "color", Color(1.0, 0.6, 0.1, 1.0), 0.5)
