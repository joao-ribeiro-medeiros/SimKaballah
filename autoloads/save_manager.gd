extends Node

const SAVE_DIR := "user://saves/"


func save_game(slot_name: String) -> bool:
	var dir_path := SAVE_DIR + slot_name + "/"
	DirAccess.make_dir_recursive_absolute(dir_path)

	# Game state
	var game_state := {
		"elapsed_game_minutes": GameClock.elapsed_game_minutes,
		"time_scale": GameClock.time_scale,
		"current_location": PartyManager.current_location,
		"travel_path": PartyManager.travel_path,
		"formation": PartyManager.formation,
	}

	# Save party
	var party_data: Array[Dictionary] = []
	for mago in PartyManager.magos:
		party_data.append(_serialize_mago(mago))

	# Save cosmic state
	var cosmic_data := {
		"creation": CosmicBalance.state.creation,
		"destruction": CosmicBalance.state.destruction,
		"conservation": CosmicBalance.state.conservation,
	}

	# Save chronicle
	var chronicle_data: Array[Dictionary] = []
	for entry in Chronicle.entries:
		chronicle_data.append(_serialize_chronicle_entry(entry))

	# Save encounters state
	var encounter_data := {
		"cooldowns": EncounterManager.cooldowns.duplicate(),
	}

	# Meta
	var meta := {
		"save_name": slot_name,
		"timestamp": Time.get_datetime_string_from_system(),
		"version": "0.1.0",
	}

	# Write JSON files
	_save_json(dir_path + "game_state.json", game_state)
	_save_json(dir_path + "party.json", party_data)
	_save_json(dir_path + "cosmic.json", cosmic_data)
	_save_json(dir_path + "chronicle.json", chronicle_data)
	_save_json(dir_path + "encounters.json", encounter_data)
	_save_json(dir_path + "meta.json", meta)

	return true


func load_game(slot_name: String) -> bool:
	var dir_path := SAVE_DIR + slot_name + "/"

	var game_state = _load_json(dir_path + "game_state.json")
	var party_data = _load_json(dir_path + "party.json")
	var cosmic_data = _load_json(dir_path + "cosmic.json")
	var chronicle_data = _load_json(dir_path + "chronicle.json")
	var encounter_data = _load_json(dir_path + "encounters.json")

	if game_state == null or party_data == null:
		return false

	# Restore game clock
	GameClock.elapsed_game_minutes = game_state.get("elapsed_game_minutes", 0.0)
	GameClock.set_time_scale(game_state.get("time_scale", 1.0))

	# Restore party
	PartyManager.magos.clear()
	PartyManager.formation.clear()
	for mago_dict in party_data:
		var mago := _deserialize_mago(mago_dict)
		PartyManager.magos.append(mago)
	PartyManager.current_location = game_state.get("current_location", "copacabana")
	PartyManager.formation = Array(game_state.get("formation", []))
	PartyManager.travel_path = Array(game_state.get("travel_path", []))

	# Restore cosmic
	if cosmic_data:
		var cs := CosmicState.new()
		cs.creation = cosmic_data.get("creation", 0.333)
		cs.destruction = cosmic_data.get("destruction", 0.333)
		cs.conservation = cosmic_data.get("conservation", 0.334)
		CosmicBalance.load_state(cs)

	# Restore chronicle
	if chronicle_data:
		Chronicle.entries.clear()
		for entry_dict in chronicle_data:
			Chronicle.entries.append(_deserialize_chronicle_entry(entry_dict))

	# Restore encounters
	if encounter_data:
		EncounterManager.cooldowns = encounter_data.get("cooldowns", {})

	return true


func get_save_slots() -> Array[String]:
	var slots: Array[String] = []
	var dir := DirAccess.open(SAVE_DIR)
	if dir == null:
		return slots
	dir.list_dir_begin()
	var folder := dir.get_next()
	while folder != "":
		if dir.current_is_dir() and not folder.begins_with("."):
			slots.append(folder)
		folder = dir.get_next()
	return slots


func delete_save(slot_name: String) -> void:
	var dir_path := SAVE_DIR + slot_name + "/"
	var dir := DirAccess.open(dir_path)
	if dir:
		dir.list_dir_begin()
		var file := dir.get_next()
		while file != "":
			if not dir.current_is_dir():
				dir.remove(file)
			file = dir.get_next()
		DirAccess.remove_absolute(dir_path)


func _save_json(path: String, data) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))


func _load_json(path: String):
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return null
	var json := JSON.new()
	var err := json.parse(file.get_as_text())
	if err != OK:
		return null
	return json.data


func _serialize_mago(mago: MagoStats) -> Dictionary:
	return {
		"mago_name": mago.mago_name,
		"portrait_path": mago.portrait_path,
		"tradition": mago.tradition,
		"stamina": mago.stamina,
		"health": mago.health,
		"experience": mago.experience,
		"arete": mago.arete,
		"paradox": mago.paradox,
		"intensity": mago.intensity,
		"strength": mago.strength,
		"dexterity": mago.dexterity,
		"stamina_attr": mago.stamina_attr,
		"charisma": mago.charisma,
		"manipulation": mago.manipulation,
		"appearance": mago.appearance,
		"intelligence": mago.intelligence,
		"wits": mago.wits,
		"perception": mago.perception,
		"correspondence": mago.correspondence,
		"entropy": mago.entropy,
		"forces": mago.forces,
		"life": mago.life,
		"matter": mago.matter,
		"mind": mago.mind,
		"prime": mago.prime,
		"spirit": mago.spirit,
		"time_sphere": mago.time_sphere,
		"relationships": mago.relationships,
	}


func _deserialize_mago(data: Dictionary) -> MagoStats:
	var mago := MagoStats.new()
	for key in data:
		if key == "relationships":
			mago.relationships = data[key]
		else:
			mago.set(key, data[key])
	return mago


func _serialize_chronicle_entry(entry: ChronicleEntry) -> Dictionary:
	return {
		"game_timestamp": entry.game_timestamp,
		"mago_name": entry.mago_name,
		"entry_type": entry.entry_type,
		"title": entry.title,
		"narrative_text": entry.narrative_text,
		"stat_changes": entry.stat_changes,
		"location_id": entry.location_id,
	}


func _deserialize_chronicle_entry(data: Dictionary) -> ChronicleEntry:
	var entry := ChronicleEntry.new()
	entry.game_timestamp = data.get("game_timestamp", 0.0)
	entry.mago_name = data.get("mago_name", "")
	entry.entry_type = data.get("entry_type", 0)
	entry.title = data.get("title", "")
	entry.narrative_text = data.get("narrative_text", "")
	entry.stat_changes = data.get("stat_changes", {})
	entry.location_id = data.get("location_id", "")
	return entry
