extends Camera2D

const ZOOM_MIN := Vector2(0.5, 0.5)
const ZOOM_MAX := Vector2(3.0, 3.0)
const ZOOM_STEP := 0.1

var _dragging := false
var _drag_start := Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	# Scroll to zoom
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom = (zoom + Vector2(ZOOM_STEP, ZOOM_STEP)).clamp(ZOOM_MIN, ZOOM_MAX)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom = (zoom - Vector2(ZOOM_STEP, ZOOM_STEP)).clamp(ZOOM_MIN, ZOOM_MAX)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			_dragging = event.pressed
			_drag_start = event.position
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_dragging = event.pressed
			_drag_start = event.position
			get_viewport().set_input_as_handled()

	# Drag to pan
	if event is InputEventMouseMotion and _dragging:
		var delta: Vector2 = event.position - _drag_start
		_drag_start = event.position
		position -= delta / zoom
		_clamp_position()
		get_viewport().set_input_as_handled()


func _clamp_position() -> void:
	position.x = clampf(position.x, limit_left, limit_right)
	position.y = clampf(position.y, limit_top, limit_bottom)
