extends PanelContainer

signal mago_dropped(mago: MagoStats)


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if data is Dictionary and data.get("type") == "mago":
		return true
	return false


func _drop_data(_at_position: Vector2, data: Variant) -> void:
	if data is Dictionary and data.get("type") == "mago":
		var mago: MagoStats = data.get("mago")
		if mago:
			mago_dropped.emit(mago)
