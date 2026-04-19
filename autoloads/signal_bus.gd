extends Node

# Time
signal time_tick(delta_game_seconds: float)
signal time_scale_changed(new_scale: float)
signal game_paused(is_paused: bool)

# Encounters
signal encounter_spawned(encounter_def, location_id: String)
signal encounter_started(encounter_def, assigned_magos: Array)
signal encounter_resolved(outcome)

# Mago
signal mago_stat_changed(mago, stat_name: String, old_val, new_val)
signal mago_ascended(mago)

# Cosmic
signal cosmic_shift(creation: float, destruction: float, conservation: float)
signal cosmic_crisis_resolved()

# Narrative
signal chronicle_entry_added(entry)

# Navigation
signal party_moved(destination_location_id: String)
signal party_arrived(location_id: String)
signal location_clicked(location_id: String)
