extends Area2D

@export var location_id: String = ""
@export var location_name: String = ""
@export var connected_locations: Array[String] = []

@onready var label: Label = $Label
@onready var dot: Polygon2D = $Dot
@onready var encounter_ring: Polygon2D = $EncounterRing
@onready var encounter_label: Label = $EncounterLabel

var _has_encounter: bool = false
var _is_hovered: bool = false
var _encounter_tween: Tween = null


func _ready() -> void:
	label.text = location_name
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	if encounter_ring:
		encounter_ring.hide()
	if encounter_label:
		encounter_label.hide()


func _on_mouse_entered() -> void:
	_is_hovered = true
	if not _has_encounter:
		modulate = Color(1.3, 1.3, 1.3)


func _on_mouse_exited() -> void:
	_is_hovered = false
	if not _has_encounter:
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
		if encounter_label:
			encounter_label.show()
		_start_pulse()
	else:
		if encounter_ring:
			encounter_ring.hide()
		if encounter_label:
			encounter_label.hide()
		if dot:
			dot.color = Color(1, 0.85, 0.4, 0.9)
		modulate = Color.WHITE


func set_highlight(on: bool) -> void:
	if on:
		modulate = Color(1.4, 1.3, 0.8)
	else:
		if _has_encounter:
			pass # pulse handles modulate
		elif _is_hovered:
			modulate = Color(1.3, 1.3, 1.3)
		else:
			modulate = Color.WHITE


func _start_pulse() -> void:
	if dot == null:
		return
	_encounter_tween = create_tween().set_loops()
	# Pulse the dot red/orange
	_encounter_tween.tween_property(dot, "color", Color(1.0, 0.15, 0.05, 1.0), 0.6)
	_encounter_tween.tween_property(dot, "color", Color(1.0, 0.5, 0.05, 1.0), 0.6)
	# Also pulse the encounter ring opacity
	if encounter_ring:
		var ring_tween: Tween = create_tween().set_loops()
		ring_tween.tween_property(encounter_ring, "modulate:a", 1.0, 0.6)
		ring_tween.tween_property(encounter_ring, "modulate:a", 0.4, 0.6)
