extends CanvasLayer

@onready var overlay: ColorRect = $Overlay


func play_paradox() -> void:
	if overlay == null:
		return
	overlay.color = Color(0.5, 0, 0.5, 0)
	overlay.show()
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", 0.4, 0.3)
	tween.tween_property(overlay, "color:a", 0.0, 0.7)
	tween.tween_callback(func(): overlay.hide())
