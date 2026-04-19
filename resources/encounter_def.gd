class_name EncounterDef
extends Resource

@export var id: String = ""
@export var title: String = ""
@export_multiline var description: String = ""
@export var location_id: String = ""
@export var encounter_type: Enums.EncounterType = Enums.EncounterType.RANDOM
@export var difficulty: int = 1
@export var resolution_stat: String = "" # sphere name or attribute
@export var required_spheres: Array[String] = []
@export var min_magos: int = 1
@export var max_magos: int = 3

# Effects on success/failure
@export var success_xp: int = 50
@export var failure_xp: int = 10
@export_multiline var success_narrative: String = ""
@export_multiline var failure_narrative: String = ""

# Cosmic impact on success: {creation: float, destruction: float, conservation: float}
@export var cosmic_impact: Dictionary = {}

# Timing (in game minutes)
@export var duration_minutes: float = 30.0
@export var expiry_minutes: float = 300.0
@export var cooldown_minutes: float = 600.0

# Dilemma (optional)
@export_multiline var dilemma_text: String = ""
@export var dilemma_options: Array[Dictionary] = []
# Each option: {text: String, stat: String, difficulty: int, cosmic_impact: Dictionary, narrative: String}

# Spawn probability per tick (0.0 to 1.0)
@export var spawn_chance: float = 0.1
