extends PanelContainer

@onready var filter_option: OptionButton = %FilterOption
@onready var entries_container: VBoxContainer = %EntriesContainer

var _filter_mago: String = "" # empty = all


func _ready() -> void:
	SignalBus.chronicle_entry_added.connect(_on_entry_added)
	filter_option.item_selected.connect(_on_filter_changed)
	_build_filter_options()


func _build_filter_options() -> void:
	filter_option.clear()
	filter_option.add_item("All Magos", 0)
	for i in range(PartyManager.magos.size()):
		filter_option.add_item(PartyManager.magos[i].mago_name, i + 1)


func _on_filter_changed(idx: int) -> void:
	if idx == 0:
		_filter_mago = ""
	else:
		_filter_mago = filter_option.get_item_text(idx)
	_rebuild_entries()


func _rebuild_entries() -> void:
	for child in entries_container.get_children():
		child.queue_free()

	var entries: Array[ChronicleEntry]
	if _filter_mago.is_empty():
		entries = Chronicle.get_recent(50)
	else:
		entries = Chronicle.get_mago_chronicle(_filter_mago)

	# Show most recent first
	entries.reverse()
	for entry in entries:
		_add_entry_widget(entry)


func _on_entry_added(entry: ChronicleEntry) -> void:
	if not _filter_mago.is_empty() and entry.mago_name != _filter_mago:
		return
	_add_entry_widget(entry, true)


func _add_entry_widget(entry: ChronicleEntry, prepend: bool = false) -> void:
	var panel := PanelContainer.new()

	var vbox := VBoxContainer.new()
	panel.add_child(vbox)

	var header := Label.new()
	var time_str := "Day %d" % (int(entry.game_timestamp / 1440) + 1)
	header.text = "[%s] %s" % [time_str, entry.title]
	header.add_theme_font_size_override("font_size", 13)
	header.add_theme_color_override("font_color", _get_entry_color(entry.entry_type))
	vbox.add_child(header)

	var body := RichTextLabel.new()
	body.bbcode_enabled = true
	body.fit_content = true
	body.text = entry.narrative_text
	body.custom_minimum_size = Vector2(0, 40)
	body.scroll_active = false
	vbox.add_child(body)

	if prepend:
		entries_container.move_child(panel, 0)
		entries_container.add_child(panel)
		entries_container.move_child(panel, 0)
	else:
		entries_container.add_child(panel)


func _get_entry_color(entry_type: ChronicleEntry.EntryType) -> Color:
	match entry_type:
		ChronicleEntry.EntryType.ENCOUNTER: return Color(0.9, 0.8, 0.3)
		ChronicleEntry.EntryType.ADVANCEMENT: return Color(0.3, 0.9, 0.5)
		ChronicleEntry.EntryType.COSMIC_SHIFT: return Color(0.6, 0.3, 0.9)
		ChronicleEntry.EntryType.ASCENSION: return Color(1.0, 0.8, 0.0)
		ChronicleEntry.EntryType.TRAVEL: return Color(0.5, 0.7, 0.9)
		ChronicleEntry.EntryType.RELATIONSHIP: return Color(0.9, 0.5, 0.6)
		ChronicleEntry.EntryType.CRISIS: return Color(0.9, 0.2, 0.2)
		_: return Color.WHITE
