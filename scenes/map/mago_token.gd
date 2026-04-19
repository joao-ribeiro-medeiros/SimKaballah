extends Node2D

var mago: MagoStats = null
var is_selected: bool = false
var click_radius: float = 25.0

@onready var shape: Polygon2D = $Shape
@onready var outline: Polygon2D = $Outline
@onready var initial_label: Label = $InitialLabel
@onready var name_label: Label = $NameLabel

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
	if name_label:
		name_label.text = mago.mago_name


func is_click_inside(world_pos: Vector2) -> bool:
	return position.distance_to(world_pos) <= click_radius


func set_selected(selected: bool) -> void:
	is_selected = selected
	if selected:
		modulate = Color(1.5, 1.5, 1.5, 1.0)
		scale = Vector2(1.4, 1.4)
		if outline:
			outline.color = Color(1, 1, 0, 1) # gold outline when selected
	else:
		modulate = Color(1, 1, 1, 1)
		scale = Vector2(1, 1)
		if outline:
			outline.color = Color(1, 1, 1, 0.8)


func snap_to(pos: Vector2) -> void:
	position = pos
