extends Control

# Simple trial resolution visual feedback
# Shows a spinning glyph that lands on success/failure

@onready var glyph_label: Label = %GlyphLabel
@onready var result_label: Label = %ResultLabel

var _glyphs := ["◆", "◇", "★", "☆", "●", "○", "▲", "△"]
var _spinning := false


func play_resolution(success: bool) -> void:
	show()
	_spinning = true
	result_label.text = ""

	var tween := create_tween()
	# Spin through glyphs for 1.5 seconds
	for i in range(15):
		tween.tween_callback(func():
			glyph_label.text = _glyphs.pick_random()
		)
		tween.tween_interval(0.1)

	# Land on result
	tween.tween_callback(func():
		_spinning = false
		if success:
			glyph_label.text = "★"
			glyph_label.modulate = Color.GOLD
			result_label.text = "SUCCESS"
			result_label.modulate = Color.GREEN
		else:
			glyph_label.text = "◇"
			glyph_label.modulate = Color.DIM_GRAY
			result_label.text = "FAILURE"
			result_label.modulate = Color.RED
	)

	# Hide after 2 seconds total
	tween.tween_interval(1.0)
	tween.tween_callback(func(): hide())
