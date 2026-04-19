extends Node

var encounter_catalog: Array[EncounterDef] = []
var active_encounters: Dictionary = {} # location_id -> EncounterDef
var cooldowns: Dictionary = {} # encounter_id -> remaining_minutes
var _encounter_timers: Dictionary = {} # location_id -> remaining_expiry_minutes


func _ready() -> void:
	SignalBus.time_tick.connect(_on_time_tick)


func _on_time_tick(delta_game_seconds: float) -> void:
	var delta_minutes := delta_game_seconds / 60.0
	# Update cooldowns
	var expired_cooldowns: Array[String] = []
	for enc_id in cooldowns:
		cooldowns[enc_id] -= delta_minutes
		if cooldowns[enc_id] <= 0.0:
			expired_cooldowns.append(enc_id)
	for enc_id in expired_cooldowns:
		cooldowns.erase(enc_id)

	# Update expiry timers
	var expired_encounters: Array[String] = []
	for loc_id in _encounter_timers:
		_encounter_timers[loc_id] -= delta_minutes
		if _encounter_timers[loc_id] <= 0.0:
			expired_encounters.append(loc_id)
	for loc_id in expired_encounters:
		_encounter_timers.erase(loc_id)
		active_encounters.erase(loc_id)
		SignalBus.encounter_expired.emit(loc_id)


func tick() -> void:
	_try_spawn_encounters()


func _try_spawn_encounters() -> void:
	var spawn_modifier := CosmicBalance.get_spawn_rate_modifier()

	for enc_def in encounter_catalog:
		if enc_def.id in cooldowns:
			continue
		if enc_def.location_id in active_encounters:
			continue
		var chance := enc_def.spawn_chance * spawn_modifier
		if randf() < chance:
			_spawn_encounter(enc_def)


func _spawn_encounter(enc_def: EncounterDef) -> void:
	active_encounters[enc_def.location_id] = enc_def
	_encounter_timers[enc_def.location_id] = enc_def.expiry_minutes
	SignalBus.encounter_spawned.emit(enc_def, enc_def.location_id)


func get_encounter_at(location_id: String):
	return active_encounters.get(location_id, null)


func has_encounter_at(location_id: String) -> bool:
	return location_id in active_encounters


func start_encounter(location_id: String, assigned_magos: Array) -> void:
	var enc_def = active_encounters.get(location_id)
	if enc_def == null:
		return
	SignalBus.encounter_started.emit(enc_def, assigned_magos)


func resolve_encounter(enc_def: EncounterDef, assigned_magos: Array, dilemma_choice: int = -1) -> EncounterOutcome:
	var stat_name := enc_def.resolution_stat
	var difficulty := enc_def.difficulty

	# If dilemma chosen, override stat and difficulty
	if dilemma_choice >= 0 and dilemma_choice < enc_def.dilemma_options.size():
		var option: Dictionary = enc_def.dilemma_options[dilemma_choice]
		stat_name = option.get("stat", stat_name)
		difficulty = option.get("difficulty", difficulty)

	var result := TrialResolver.find_best_resolver(assigned_magos, stat_name)
	var best_mago: MagoStats = result[0]
	var effective_skill: int = result[1]

	var success := TrialResolver.resolve(effective_skill, difficulty)

	var outcome := EncounterOutcome.new()
	outcome.encounter_id = enc_def.id
	outcome.encounter_title = enc_def.title
	outcome.location_id = enc_def.location_id
	outcome.success = success
	outcome.resolver_mago = best_mago.mago_name if best_mago else ""
	outcome.stat_used = stat_name
	outcome.skill_value = effective_skill
	outcome.difficulty = difficulty
	outcome.dilemma_chosen = dilemma_choice
	outcome.game_timestamp = GameClock.elapsed_game_minutes

	for m in assigned_magos:
		outcome.assigned_magos.append(m.mago_name)

	# Apply XP
	var xp_modifier := CosmicBalance.get_xp_modifier()
	var base_xp := enc_def.success_xp if success else enc_def.failure_xp
	outcome.xp_awarded = int(base_xp * xp_modifier)

	for mago in assigned_magos:
		var old_xp: int = mago.experience
		mago.experience += outcome.xp_awarded
		SignalBus.mago_stat_changed.emit(mago, "experience", old_xp, mago.experience)

	# Cosmic impact
	var impact := enc_def.cosmic_impact
	if dilemma_choice >= 0 and dilemma_choice < enc_def.dilemma_options.size():
		impact = enc_def.dilemma_options[dilemma_choice].get("cosmic_impact", impact)
	if success and not impact.is_empty():
		outcome.cosmic_impact = impact
		CosmicBalance.apply_shift(impact)

	# Narrative
	var narrative_template := enc_def.success_narrative if success else enc_def.failure_narrative
	if dilemma_choice >= 0 and dilemma_choice < enc_def.dilemma_options.size():
		narrative_template = enc_def.dilemma_options[dilemma_choice].get("narrative", narrative_template)
	outcome.narrative = _fill_narrative(narrative_template, outcome, best_mago)

	# Relationships: shared encounter
	_update_relationships(assigned_magos, success)

	# Health effects on failure in destruction crisis
	if not success and CosmicBalance.is_in_crisis() and CosmicBalance.get_dominant() == Enums.CosmicTendency.DESTRUCTION:
		if best_mago and best_mago.health == Enums.Health.READY:
			var old_health := best_mago.health
			best_mago.health = Enums.Health.HURT
			SignalBus.mago_stat_changed.emit(best_mago, "health", old_health, best_mago.health)

	# FIND_MAGO: recruit new mago on success
	if success and enc_def.encounter_type == Enums.EncounterType.FIND_MAGO and not enc_def.reward_mago.is_empty():
		var new_mago := _create_mago_from_template(enc_def.reward_mago, enc_def.location_id)
		if new_mago:
			PartyManager.add_mago(new_mago)
			outcome.recruited_mago_name = new_mago.mago_name
			SignalBus.mago_stat_changed.emit(new_mago, "recruited", 0, 1)

	# Cooldown and cleanup
	cooldowns[enc_def.id] = enc_def.cooldown_minutes
	active_encounters.erase(enc_def.location_id)
	_encounter_timers.erase(enc_def.location_id)

	SignalBus.encounter_resolved.emit(outcome)
	return outcome


func _fill_narrative(template: String, outcome: EncounterOutcome, mago: MagoStats) -> String:
	if template.is_empty():
		var result_word := "succeeded" if outcome.success else "failed"
		return "%s %s at %s using %s." % [outcome.resolver_mago, result_word, outcome.encounter_title, outcome.stat_used]
	var text := template
	text = text.replace("{mago_name}", outcome.resolver_mago)
	text = text.replace("{encounter_title}", outcome.encounter_title)
	text = text.replace("{location}", outcome.location_id)
	text = text.replace("{sphere}", outcome.stat_used)
	text = text.replace("{result}", "succeeded" if outcome.success else "failed")
	text = text.replace("{recruited_mago}", outcome.recruited_mago_name)
	return text


func _update_relationships(magos: Array, success: bool) -> void:
	for i in range(magos.size()):
		for j in range(i + 1, magos.size()):
			var delta := 1 if success else -1
			magos[i].modify_relationship(magos[j].mago_name, delta)
			magos[j].modify_relationship(magos[i].mago_name, delta)


func register_encounter(enc_def: EncounterDef) -> void:
	encounter_catalog.append(enc_def)


func load_catalog(encounters: Array[EncounterDef]) -> void:
	encounter_catalog = encounters


func _create_mago_from_template(template: Dictionary, location_id: String) -> MagoStats:
	if PartyManager.magos.size() >= PartyManager.MAX_PARTY_SIZE:
		return null
	var mago := MagoStats.new()
	mago.mago_name = template.get("mago_name", "Unknown Mago")
	mago.tradition = template.get("tradition", "Orphan")
	mago.arete = template.get("arete", 1)
	mago.current_location = location_id
	var attrs: Dictionary = template.get("attributes", {})
	for attr_name in attrs:
		match attr_name:
			"strength": mago.strength = attrs[attr_name]
			"dexterity": mago.dexterity = attrs[attr_name]
			"stamina_attr": mago.stamina_attr = attrs[attr_name]
			"charisma": mago.charisma = attrs[attr_name]
			"manipulation": mago.manipulation = attrs[attr_name]
			"appearance": mago.appearance = attrs[attr_name]
			"intelligence": mago.intelligence = attrs[attr_name]
			"wits": mago.wits = attrs[attr_name]
			"perception": mago.perception = attrs[attr_name]
	var spheres: Dictionary = template.get("spheres", {})
	for sphere_name in spheres:
		mago.set_sphere(sphere_name, spheres[sphere_name])
	return mago
