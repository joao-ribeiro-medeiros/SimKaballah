extends CanvasLayer

@onready var overlay: ColorRect = $Overlay
@onready var label: Label = $Label


func play_ascension(mago_name: String) -> void:
	if overlay == null:
		return
	overlay.color = Color(1, 0.85, 0, 0)
	label.text = "%s\nASCENDS" % mago_name
	label.modulate.a = 0.0
	overlay.show()
	label.show()

	var tween := create_tween()
	tween.tween_property(overlay, "color:a", 0.6, 1.0)
	tween.parallel().tween_property(label, "modulate:a", 1.0, 1.5)
	tween.tween_interval(3.0)
	tween.tween_property(overlay, "color:a", 0.0, 2.0)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 2.0)
	tween.tween_callback(func():
		overlay.hide()
		label.hide()
	)
