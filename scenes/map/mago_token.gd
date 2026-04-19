extends Node2D

var mago: MagoStats = null

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
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if mago:
			var sheet = get_tree().get_first_node_in_group("mago_sheet")
			if sheet and sheet.has_method("show_mago"):
				sheet.show_mago(mago)
