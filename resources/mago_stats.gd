class_name MagoStats
extends Resource

# Identity
@export var mago_name: String = "Unknown Mago"
@export var portrait_path: String = ""
@export var tradition: String = ""

# Basic / Mundane
@export var stamina: Enums.Stamina = Enums.Stamina.READY
@export var health: Enums.Health = Enums.Health.READY
@export var experience: int = 0
@export var arete: int = 1
@export var paradox: Enums.Paradox = Enums.Paradox.NONE
@export var intensity: int = 0

# Physical Attributes (0-5)
@export_range(0, 5) var strength: int = 1
@export_range(0, 5) var dexterity: int = 1
@export_range(0, 5) var stamina_attr: int = 1

# Social Attributes (0-5)
@export_range(0, 5) var charisma: int = 1
@export_range(0, 5) var manipulation: int = 1
@export_range(0, 5) var appearance: int = 1

# Mental Attributes (0-5)
@export_range(0, 5) var intelligence: int = 1
@export_range(0, 5) var wits: int = 1
@export_range(0, 5) var perception: int = 1

# Nine Spheres (0-5 each)
@export_range(0, 5) var correspondence: int = 0
@export_range(0, 5) var entropy: int = 0
@export_range(0, 5) var forces: int = 0
@export_range(0, 5) var life: int = 0
@export_range(0, 5) var matter: int = 0
@export_range(0, 5) var mind: int = 0
@export_range(0, 5) var prime: int = 0
@export_range(0, 5) var spirit: int = 0
@export_range(0, 5) var time_sphere: int = 0

# Relationships: mago_name -> bond value (-5 to +5)
@export var relationships: Dictionary = {}

# Location & Travel
@export var current_location: String = "lapa"
var travel_path: Array[String] = []
var is_traveling: bool = false

# Whether this mago is currently deployed to an encounter
var is_deployed: bool = false


func get_sphere(sphere_name: String) -> int:
	match sphere_name:
		"correspondence": return correspondence
		"entropy": return entropy
		"forces": return forces
		"life": return life
		"matter": return matter
		"mind": return mind
		"prime": return prime
		"spirit": return spirit
		"time_sphere", "time": return time_sphere
		_: return 0


func set_sphere(sphere_name: String, value: int) -> void:
	value = clampi(value, 0, 5)
	match sphere_name:
		"correspondence": correspondence = value
		"entropy": entropy = value
		"forces": forces = value
		"life": life = value
		"matter": matter = value
		"mind": mind = value
		"prime": prime = value
		"spirit": spirit = value
		"time_sphere", "time": time_sphere = value


func get_attribute(attr_name: String) -> int:
	match attr_name:
		"strength": return strength
		"dexterity": return dexterity
		"stamina_attr": return stamina_attr
		"charisma": return charisma
		"manipulation": return manipulation
		"appearance": return appearance
		"intelligence": return intelligence
		"wits": return wits
		"perception": return perception
		_: return 0


func get_stat(stat_name: String) -> int:
	var sphere_val := get_sphere(stat_name)
	if sphere_val > 0 or stat_name in ["correspondence", "entropy", "forces", "life", "matter", "mind", "prime", "spirit", "time_sphere", "time"]:
		return sphere_val
	return get_attribute(stat_name)


func get_all_sphere_names() -> Array[String]:
	return ["correspondence", "entropy", "forces", "life", "matter", "mind", "prime", "spirit", "time_sphere"]


func get_all_attribute_names() -> Array[String]:
	return ["strength", "dexterity", "stamina_attr", "charisma", "manipulation", "appearance", "intelligence", "wits", "perception"]


func is_available() -> bool:
	return not is_deployed and health != Enums.Health.GRAVELY_WOUNDED and stamina != Enums.Stamina.INCAPACITATED


func get_relationship(other_name: String) -> int:
	return relationships.get(other_name, 0)


func modify_relationship(other_name: String, delta: int) -> void:
	var current := get_relationship(other_name)
	relationships[other_name] = clampi(current + delta, -5, 5)


func sphere_advance_cost(sphere_name: String) -> int:
	var current := get_sphere(sphere_name)
	return (current + 1) * 50


func arete_advance_cost() -> int:
	return arete * 100
