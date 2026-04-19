extends PanelContainer

@onready var front_row: HBoxContainer = %FrontRow
@onready var back_row: HBoxContainer = %BackRow

var _dragging_mago: String = ""


func _ready() -> void:
	call_deferred("_build_formation")


func _build_formation() -> void:
	for child in front_row.get_children():
		child.queue_free()
	for child in back_row.get_children():
		child.queue_free()

	for i in range(PartyManager.formation.size()):
		var mago_name: String = PartyManager.formation[i]
		var mago := PartyManager.get_mago(mago_name)
		if mago == null:
			continue

		var slot := _create_slot(mago, i)
		if i < 3:
			front_row.add_child(slot)
		else:
			back_row.add_child(slot)


func _create_slot(mago: MagoStats, index: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(80, 80)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	panel.add_child(vbox)

	var name_label := Label.new()
	name_label.text = mago.mago_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 11)
	vbox.add_child(name_label)

	var row_label := Label.new()
	row_label.text = "Front" if index < 3 else "Back"
	row_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row_label.add_theme_font_size_override("font_size", 9)
	row_label.modulate = Color(0.6, 0.6, 0.6)
	vbox.add_child(row_label)

	panel.set_meta("mago_name", mago.mago_name)
	panel.set_meta("index", index)

	return panel
