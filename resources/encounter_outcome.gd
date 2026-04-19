class_name EncounterOutcome
extends Resource

@export var encounter_id: String = ""
@export var encounter_title: String = ""
@export var location_id: String = ""
@export var success: bool = false
@export var assigned_magos: Array[String] = [] # mago names
@export var resolver_mago: String = "" # who resolved it
@export var stat_used: String = ""
@export var skill_value: int = 0
@export var difficulty: int = 0
@export var xp_awarded: int = 0
@export var cosmic_impact: Dictionary = {}
@export var narrative: String = ""
@export var dilemma_chosen: int = -1 # index of dilemma option, -1 if no dilemma
@export var game_timestamp: float = 0.0
