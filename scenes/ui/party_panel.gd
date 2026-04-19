extends PanelContainer

@onready var roster_container: VBoxContainer = %RosterContainer

var _roster_entry_scene: PackedScene = null


func _ready() -> void:
	SignalBus.mago_stat_changed.connect(_on_mago_stat_changed)
	call_deferred("_build_roster")


func _build_roster() -> void:
	for child in roster_container.get_children():
		child.queue_free()

	for mago in PartyManager.magos:
		var entry := _create_roster_entry(mago)
		roster_container.add_child(entry)


func _create_roster_entry(mago: MagoStats) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(200, 60)

	var hbox := HBoxContainer.new()
	panel.add_child(hbox)

	# Portrait placeholder
	var portrait := TextureRect.new()
	portrait.custom_minimum_size = Vector2(48, 48)
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.name = "Portrait"
	hbox.add_child(portrait)

	var vbox := VBoxContainer.new()
	hbox.add_child(vbox)

	var name_label := Label.new()
	name_label.text = mago.mago_name
	name_label.name = "NameLabel"
	name_label.add_theme_font_size_override("font_size", 14)
	vbox.add_child(name_label)

	var info_label := Label.new()
	info_label.text = "Arete %d | %s" % [mago.arete, Enums.Health.keys()[mago.health]]
	info_label.name = "InfoLabel"
	info_label.add_theme_font_size_override("font_size", 11)
	info_label.modulate = Color(0.7, 0.7, 0.7)
	vbox.add_child(info_label)

	var arete_bar := ProgressBar.new()
	arete_bar.max_value = 10
	arete_bar.value = mago.arete
	arete_bar.custom_minimum_size = Vector2(120, 8)
	arete_bar.show_percentage = false
	arete_bar.name = "AreteBar"
	vbox.add_child(arete_bar)

	# Click to open sheet
	panel.gui_input.connect(func(event: InputEvent):
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_open_mago_sheet(mago)
	)

	panel.set_meta("mago_name", mago.mago_name)
	return panel


func _open_mago_sheet(mago: MagoStats) -> void:
	var sheet = get_tree().get_first_node_in_group("mago_sheet")
	if sheet and sheet.has_method("show_mago"):
		sheet.show_mago(mago)


func _on_mago_stat_changed(mago: MagoStats, _stat: String, _old, _new) -> void:
	for entry in roster_container.get_children():
		if entry.has_meta("mago_name") and entry.get_meta("mago_name") == mago.mago_name:
			var info_label = entry.find_child("InfoLabel", true, false)
			if info_label:
				info_label.text = "Arete %d | %s" % [mago.arete, Enums.Health.keys()[mago.health]]
			var arete_bar = entry.find_child("AreteBar", true, false)
			if arete_bar:
				arete_bar.value = mago.arete
			break
