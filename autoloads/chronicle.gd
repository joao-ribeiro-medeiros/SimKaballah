extends Node

var entries: Array[ChronicleEntry] = []
var _was_in_crisis: bool = false


func _ready() -> void:
	SignalBus.encounter_resolved.connect(_on_encounter_resolved)
	SignalBus.mago_stat_changed.connect(_on_mago_stat_changed)
	SignalBus.cosmic_shift.connect(_on_cosmic_shift)
	SignalBus.mago_ascended.connect(_on_mago_ascended)
	SignalBus.party_arrived.connect(_on_party_arrived)


func add_entry(entry: ChronicleEntry) -> void:
	entries.append(entry)
	SignalBus.chronicle_entry_added.emit(entry)


func get_mago_chronicle(mago_name: String) -> Array[ChronicleEntry]:
	var result: Array[ChronicleEntry] = []
	for e in entries:
		if e.mago_name == mago_name:
			result.append(e)
	return result


func get_recent(count: int = 10) -> Array[ChronicleEntry]:
	var start := maxi(0, entries.size() - count)
	var result: Array[ChronicleEntry] = []
	for i in range(start, entries.size()):
		result.append(entries[i])
	return result


func get_by_type(entry_type: ChronicleEntry.EntryType) -> Array[ChronicleEntry]:
	var result: Array[ChronicleEntry] = []
	for e in entries:
		if e.entry_type == entry_type:
			result.append(e)
	return result


func _on_encounter_resolved(outcome: EncounterOutcome) -> void:
	var entry := ChronicleEntry.new()
	entry.game_timestamp = outcome.game_timestamp
	entry.mago_name = outcome.resolver_mago
	entry.entry_type = ChronicleEntry.EntryType.ENCOUNTER
	entry.title = outcome.encounter_title
	entry.narrative_text = outcome.narrative
	entry.location_id = outcome.location_id
	entry.stat_changes = {"experience": {"old": 0, "new": outcome.xp_awarded}}
	add_entry(entry)


func _on_mago_stat_changed(mago: MagoStats, stat_name: String, old_val, new_val) -> void:
	# Only log significant stat changes (arete, spheres) not every XP tick
	if stat_name == "experience":
		return
	if stat_name == "arete":
		var entry := ChronicleEntry.new()
		entry.game_timestamp = GameClock.elapsed_game_minutes
		entry.mago_name = mago.mago_name
		entry.entry_type = ChronicleEntry.EntryType.ADVANCEMENT
		entry.title = "Arete Advancement"
		entry.narrative_text = "%s has reached Arete %d, deepening their understanding of the Awakened world." % [mago.mago_name, new_val]
		entry.stat_changes = {stat_name: {"old": old_val, "new": new_val}}
		add_entry(entry)
	elif stat_name in ["correspondence", "entropy", "forces", "life", "matter", "mind", "prime", "spirit", "time_sphere"]:
		var entry := ChronicleEntry.new()
		entry.game_timestamp = GameClock.elapsed_game_minutes
		entry.mago_name = mago.mago_name
		entry.entry_type = ChronicleEntry.EntryType.ADVANCEMENT
		entry.title = "%s Sphere Growth" % stat_name.capitalize()
		entry.narrative_text = "%s has advanced their mastery of %s to level %d." % [mago.mago_name, stat_name.capitalize(), new_val]
		entry.stat_changes = {stat_name: {"old": old_val, "new": new_val}}
		add_entry(entry)


func _on_cosmic_shift(creation: float, destruction: float, conservation: float) -> void:
	var in_crisis := CosmicBalance.is_in_crisis()
	if in_crisis and not _was_in_crisis:
		# Crisis just started
		var dominant := CosmicBalance.get_dominant()
		var tendency_name: String
		match dominant:
			Enums.CosmicTendency.CREATION:
				tendency_name = "Creation"
			Enums.CosmicTendency.DESTRUCTION:
				tendency_name = "Destruction"
			_:
				tendency_name = "Conservation"
		var entry := ChronicleEntry.new()
		entry.game_timestamp = GameClock.elapsed_game_minutes
		entry.entry_type = ChronicleEntry.EntryType.CRISIS
		entry.title = "Cosmic Crisis"
		entry.narrative_text = "The cosmic balance has tipped dangerously toward %s. The fabric of reality strains under the imbalance." % tendency_name
		add_entry(entry)
	elif not in_crisis and _was_in_crisis:
		# Crisis just ended
		var entry := ChronicleEntry.new()
		entry.game_timestamp = GameClock.elapsed_game_minutes
		entry.entry_type = ChronicleEntry.EntryType.CRISIS
		entry.title = "Balance Restored"
		entry.narrative_text = "The cosmic balance has been restored. Reality breathes easier once more."
		add_entry(entry)
	_was_in_crisis = in_crisis


func _on_mago_ascended(mago: MagoStats) -> void:
	var entry := ChronicleEntry.new()
	entry.game_timestamp = GameClock.elapsed_game_minutes
	entry.mago_name = mago.mago_name
	entry.entry_type = ChronicleEntry.EntryType.ASCENSION
	entry.title = "Ascension"
	entry.narrative_text = "%s has achieved Arete 10 and Ascended, transcending the boundaries of mortal understanding. The cosmos trembles." % mago.mago_name
	add_entry(entry)


func _on_party_arrived(location_id: String) -> void:
	var entry := ChronicleEntry.new()
	entry.game_timestamp = GameClock.elapsed_game_minutes
	entry.entry_type = ChronicleEntry.EntryType.TRAVEL
	entry.title = "Arrived at %s" % location_id.capitalize()
	entry.narrative_text = "The Kabbalah has arrived at %s." % location_id.capitalize()
	entry.location_id = location_id
	add_entry(entry)
