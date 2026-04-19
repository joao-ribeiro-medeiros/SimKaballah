extends Node2D

signal token_dropped(mago: MagoStats, world_position: Vector2)

var mago: MagoStats = null

var _is_dragging: bool = false
var _drag_start_pos: Vector2 = Vector2.ZERO
var _original_position: Vector2 = Vector2.ZERO
var _mouse_pressed: bool = false

const DRAG_THRESHOLD := 5.0

@onready var shape: Polygon2D = $Shape
@onready var initial_label: Label = $InitialLabel

const TRADITION_COLORS := {
	"Order of Hermes": Color(0.8, 0.15, 0.15),
	"Akashic Brotherhood": Color(0.2, 0.4, 0.9),
	"Verbena": Color(0.15, 0.7, 0.2),
	"Virtual Adepts": Color(0.1, 0.8, 0.8),
	"Dreamspeakers": Color(0.6, 0.2, 0.8),
}


func _ready() -> void:
	pass


func setup(p_mago: MagoStats) -> void:
	mago = p_mago
	var color: Color = TRADITION_COLORS.get(mago.tradition, Color(0.5, 0.5, 0.5))
	if shape:
		shape.color = color
	if initial_label:
		initial_label.text = mago.mago_name[0]


func _on_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if mago and mago.is_traveling:
				return
			_mouse_pressed = true
			_drag_start_pos = get_global_mouse_position()
			_original_position = position
		else:
			_handle_release()


func _process(_delta: float) -> void:
	if not _mouse_pressed:
		return

	if not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_handle_release()
		return

	var mouse_pos := get_global_mouse_position()
	if not _is_dragging:
		if _drag_start_pos.distance_to(mouse_pos) > DRAG_THRESHOLD:
			_is_dragging = true
			modulate.a = 0.7

	if _is_dragging:
		global_position = mouse_pos


func _handle_release() -> void:
	if not _mouse_pressed:
		return
	_mouse_pressed = false

	if _is_dragging:
		_is_dragging = false
		modulate.a = 1.0
		token_dropped.emit(mago, global_position)
	else:
		# Short click — open MagoSheet
		if mago:
			var sheet = get_tree().get_first_node_in_group("mago_sheet")
			if sheet and sheet.has_method("show_mago"):
				sheet.show_mago(mago)


func snap_to(pos: Vector2) -> void:
	position = pos
