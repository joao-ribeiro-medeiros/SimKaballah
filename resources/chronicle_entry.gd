class_name ChronicleEntry
extends Resource

enum EntryType {
	ENCOUNTER,
	ADVANCEMENT,
	COSMIC_SHIFT,
	ASCENSION,
	TRAVEL,
	RELATIONSHIP,
	CRISIS
}

@export var game_timestamp: float = 0.0
@export var mago_name: String = ""
@export var entry_type: EntryType = EntryType.ENCOUNTER
@export var title: String = ""
@export_multiline var narrative_text: String = ""
@export var stat_changes: Dictionary = {} # stat_name -> {old: val, new: val}
@export var location_id: String = ""
