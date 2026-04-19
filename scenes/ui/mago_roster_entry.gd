extends PanelContainer
## Drag source for mago deployment. Attach to roster entries via scene or set_script().
## Call setup(mago) after attaching.

var mago: MagoStats = null


func setup(p_mago: MagoStats) -> void:
	mago = p_mago


func _get_drag_data(_at_position: Vector2) -> Variant:
	if mago == null:
		return null

	# Create drag preview
	var preview := Label.new()
	preview.text = mago.mago_name
	preview.add_theme_font_size_override("font_size", 16)
	preview.modulate = Color.YELLOW
	set_drag_preview(preview)

	return {"type": "mago", "mago": mago}
