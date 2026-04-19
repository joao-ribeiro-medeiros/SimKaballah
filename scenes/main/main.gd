extends Node

@onready var rio_map: Node2D = %RioMap
@onready var encounter_panel = %EncounterPanel
@onready var mago_sheet = %MagoSheet
@onready var cosmic_panel = %CosmicPanel
@onready var chronicle_panel = %ChroniclePanel


func _ready() -> void:
	SignalBus.location_clicked.connect(_on_location_clicked)
	SignalBus.encounter_spawned.connect(_on_encounter_spawned)
	SignalBus.mago_ascended.connect(_on_mago_ascended)

	_init_starting_party()
	_load_encounter_catalog()
	_add_opening_chronicle()


func _init_starting_party() -> void:
	var templates := _create_starting_magos()
	for mago in templates:
		PartyManager.add_mago(mago)


func _create_starting_magos() -> Array[MagoStats]:
	var magos: Array[MagoStats] = []

	var m1 := MagoStats.new()
	m1.mago_name = "Luciana"
	m1.tradition = "Order of Hermes"
	m1.arete = 2
	m1.intelligence = 4
	m1.wits = 3
	m1.perception = 3
	m1.charisma = 2
	m1.manipulation = 2
	m1.dexterity = 2
	m1.forces = 2
	m1.prime = 1
	m1.correspondence = 1
	magos.append(m1)

	var m2 := MagoStats.new()
	m2.mago_name = "Rafael"
	m2.tradition = "Akashic Brotherhood"
	m2.arete = 2
	m2.strength = 4
	m2.dexterity = 4
	m2.stamina_attr = 3
	m2.perception = 2
	m2.wits = 2
	m2.charisma = 2
	m2.mind = 2
	m2.life = 1
	m2.forces = 1
	magos.append(m2)

	var m3 := MagoStats.new()
	m3.mago_name = "Isabela"
	m3.tradition = "Verbena"
	m3.arete = 2
	m3.stamina_attr = 4
	m3.charisma = 3
	m3.perception = 3
	m3.strength = 2
	m3.manipulation = 2
	m3.life = 3
	m3.spirit = 1
	m3.prime = 1
	magos.append(m3)

	var m4 := MagoStats.new()
	m4.mago_name = "Marcos"
	m4.tradition = "Virtual Adepts"
	m4.arete = 1
	m4.intelligence = 4
	m4.wits = 4
	m4.perception = 3
	m4.dexterity = 2
	m4.manipulation = 2
	m4.correspondence = 2
	m4.forces = 1
	m4.matter = 1
	magos.append(m4)

	var m5 := MagoStats.new()
	m5.mago_name = "Yara"
	m5.tradition = "Dreamspeakers"
	m5.arete = 2
	m5.perception = 4
	m5.charisma = 4
	m5.wits = 3
	m5.manipulation = 2
	m5.intelligence = 2
	m5.spirit = 3
	m5.mind = 1
	m5.entropy = 1
	magos.append(m5)

	return magos


func _add_opening_chronicle() -> void:
	var entry := ChronicleEntry.new()
	entry.game_timestamp = 0.0
	entry.entry_type = ChronicleEntry.EntryType.TRAVEL
	entry.title = "The Kabbalah Gathers"
	entry.narrative_text = "The Kabbalah gathers at the Refuge in Lapa. Five Awakened mages from diverse traditions unite under the Rio sun, drawn together by visions of cosmic imbalance. Their journey begins now."
	entry.location_id = "lapa"
	Chronicle.add_entry(entry)


func _load_encounter_catalog() -> void:
	var encounters := _create_initial_encounters()
	EncounterManager.load_catalog(encounters)


func _create_initial_encounters() -> Array[EncounterDef]:
	var encounters: Array[EncounterDef] = []

	# =============================================
	# STORY ENCOUNTERS (attribute-tested)
	# =============================================

	# --- Copacabana ---
	var e1 := EncounterDef.new()
	e1.id = "copa_spirit_tide"
	e1.title = "Spirit Tide at Copacabana"
	e1.description = "Restless spirits surge from the ocean at Copacabana, drawn by the moonlight. The Gauntlet thins dangerously."
	e1.location_id = "copacabana"
	e1.encounter_type = Enums.EncounterType.STORY
	e1.difficulty = 3
	e1.resolution_stat = "perception"
	e1.success_xp = 80
	e1.failure_xp = 20
	e1.success_narrative = "{mago_name} perceived the spirit tide's pattern and wove a barrier, calming the restless spirits at {location}."
	e1.failure_narrative = "{mago_name} couldn't perceive the spirits clearly enough. The Gauntlet weakened further."
	e1.cosmic_impact = {"conservation": 0.05, "destruction": -0.02}
	e1.spawn_chance = 0.08
	encounters.append(e1)

	# --- Centro ---
	var e2 := EncounterDef.new()
	e2.id = "centro_paradox_storm"
	e2.title = "Paradox Storm in Centro"
	e2.description = "A Paradox storm brews in Rio's financial district. Reality fractures visibly as Sleepers grow uneasy."
	e2.location_id = "centro"
	e2.encounter_type = Enums.EncounterType.COSMIC
	e2.difficulty = 4
	e2.resolution_stat = "intelligence"
	e2.success_xp = 100
	e2.failure_xp = 25
	e2.success_narrative = "{mago_name} analyzed the Paradox patterns and sealed the reality fractures in Centro before Sleepers noticed."
	e2.failure_narrative = "{mago_name} could not comprehend the Paradox storm's structure. Reality continues to warp."
	e2.cosmic_impact = {"destruction": -0.08, "conservation": 0.04}
	e2.spawn_chance = 0.06
	encounters.append(e2)

	# --- Lapa ---
	var e3 := EncounterDef.new()
	e3.id = "lapa_mind_maze"
	e3.title = "Mind Maze of Lapa"
	e3.description = "A rogue Mage has trapped Sleepers in a psychic labyrinth beneath the Arcos da Lapa."
	e3.location_id = "lapa"
	e3.encounter_type = Enums.EncounterType.STORY
	e3.difficulty = 3
	e3.resolution_stat = "wits"
	e3.success_xp = 70
	e3.failure_xp = 15
	e3.success_narrative = "{mago_name} outwitted the labyrinth's traps and freed the trapped Sleepers from the mind maze."
	e3.failure_narrative = "{mago_name} became disoriented in the mind maze. Some Sleepers remain trapped."
	e3.cosmic_impact = {"creation": 0.03, "destruction": -0.03}
	e3.spawn_chance = 0.07
	encounters.append(e3)

	# --- Santa Teresa ---
	var e4 := EncounterDef.new()
	e4.id = "santa_teresa_ley_line"
	e4.title = "Ley Line Disruption"
	e4.description = "The ancient ley line running through Santa Teresa's cobblestone streets has been corrupted. Magical energies flow erratically."
	e4.location_id = "santa_teresa"
	e4.encounter_type = Enums.EncounterType.STORY
	e4.difficulty = 3
	e4.resolution_stat = "perception"
	e4.success_xp = 75
	e4.failure_xp = 20
	e4.success_narrative = "{mago_name} perceived the ley line's disruption and restored its natural flow through Santa Teresa."
	e4.failure_narrative = "{mago_name} could not sense the corruption clearly. Magical interference persists."
	e4.cosmic_impact = {"conservation": 0.04, "creation": 0.02}
	e4.spawn_chance = 0.07
	encounters.append(e4)

	# --- Tijuca Forest ---
	var e5 := EncounterDef.new()
	e5.id = "tijuca_life_bloom"
	e5.title = "Uncontrolled Life Bloom"
	e5.description = "The Tijuca Forest has erupted in supernatural growth. Vines move with intent, and creatures mutate rapidly."
	e5.location_id = "tijuca"
	e5.encounter_type = Enums.EncounterType.COSMIC
	e5.difficulty = 4
	e5.resolution_stat = "stamina_attr"
	e5.success_xp = 90
	e5.failure_xp = 20
	e5.success_narrative = "{mago_name} endured the primal onslaught and channeled the wild life energy back into balance."
	e5.failure_narrative = "{mago_name} was overwhelmed by the primal life force. The forest continues its unnatural expansion."
	e5.cosmic_impact = {"creation": -0.06, "conservation": 0.03}
	e5.spawn_chance = 0.06
	encounters.append(e5)

	# --- Corcovado ---
	var e6 := EncounterDef.new()
	e6.id = "corcovado_vision"
	e6.title = "Vision at Corcovado"
	e6.description = "Atop Corcovado, the Cristo Redentor statue emanates a faint Quintessence glow. A vision awaits those with the insight to perceive it."
	e6.location_id = "corcovado"
	e6.encounter_type = Enums.EncounterType.STORY
	e6.difficulty = 5
	e6.resolution_stat = "intelligence"
	e6.success_xp = 150
	e6.failure_xp = 30
	e6.success_narrative = "{mago_name} received a profound vision at Corcovado, glimpsing the true nature of Ascension."
	e6.failure_narrative = "{mago_name} could feel the Quintessence but lacked the intellect to decode the vision."
	e6.cosmic_impact = {"conservation": 0.05, "creation": 0.03, "destruction": -0.05}
	e6.spawn_chance = 0.04
	encounters.append(e6)

	# --- Ipanema ---
	var e10 := EncounterDef.new()
	e10.id = "ipanema_time_loop"
	e10.title = "Time Loop at Ipanema"
	e10.description = "A section of Ipanema beach is caught in a temporal loop. Sunbathers relive the same hour endlessly."
	e10.location_id = "ipanema"
	e10.encounter_type = Enums.EncounterType.STORY
	e10.difficulty = 4
	e10.resolution_stat = "wits"
	e10.success_xp = 90
	e10.failure_xp = 20
	e10.success_narrative = "{mago_name} quickly deduced the loop's anchor point and unraveled the temporal snare at Ipanema."
	e10.failure_narrative = "{mago_name} became briefly caught in the loop before escaping. The anomaly continues."
	e10.cosmic_impact = {"conservation": -0.04, "creation": 0.02}
	e10.spawn_chance = 0.05
	encounters.append(e10)

	# =============================================
	# COMBAT ENCOUNTERS
	# =============================================

	var e7 := EncounterDef.new()
	e7.id = "pao_de_acucar_techno_patrol"
	e7.title = "Technocracy Patrol"
	e7.description = "A Technocracy HIT Mark patrol has been spotted near Pao de Acucar. They're scanning for Reality Deviants."
	e7.location_id = "pao_de_acucar"
	e7.encounter_type = Enums.EncounterType.COMBAT
	e7.difficulty = 4
	e7.resolution_stat = "dexterity"
	e7.success_xp = 100
	e7.failure_xp = 25
	e7.success_narrative = "{mago_name} outmaneuvered the HIT Mark patrol with swift reflexes, disabling their equipment."
	e7.failure_narrative = "{mago_name} was spotted by the patrol. They escaped but the Technocracy knows someone is here."
	e7.cosmic_impact = {"destruction": 0.03, "creation": -0.02}
	e7.spawn_chance = 0.06
	encounters.append(e7)

	var e8 := EncounterDef.new()
	e8.id = "rocinha_fomori_gang"
	e8.title = "Fomori Gang in Rocinha"
	e8.description = "Bane-possessed thugs terrorize the streets of Rocinha. Their unnatural strength threatens the community."
	e8.location_id = "rocinha"
	e8.encounter_type = Enums.EncounterType.COMBAT
	e8.difficulty = 4
	e8.resolution_stat = "strength"
	e8.success_xp = 95
	e8.failure_xp = 20
	e8.success_narrative = "{mago_name} overpowered the Fomori gang, driving the Banes from their hosts."
	e8.failure_narrative = "{mago_name} was driven back by the Fomori's unnatural strength. They still roam Rocinha."
	e8.cosmic_impact = {"destruction": -0.06, "conservation": 0.03}
	e8.spawn_chance = 0.06
	encounters.append(e8)

	var e9 := EncounterDef.new()
	e9.id = "botafogo_nephandi_cell"
	e9.title = "Nephandi Cell in Botafogo"
	e9.description = "Signs of Nephandi corruption have been found in a Botafogo basement. Dark rituals leave traces of anti-Quintessence."
	e9.location_id = "botafogo"
	e9.encounter_type = Enums.EncounterType.COMBAT
	e9.difficulty = 5
	e9.resolution_stat = "strength"
	e9.success_xp = 130
	e9.failure_xp = 30
	e9.success_narrative = "{mago_name} stormed the Nephandi cell and disrupted their ritual circle with raw force."
	e9.failure_narrative = "{mago_name} was repelled by the dark energies. The Nephandi cell remains active."
	e9.cosmic_impact = {"destruction": -0.08, "conservation": 0.04}
	e9.spawn_chance = 0.04
	encounters.append(e9)

	# --- Dilemma: Technocrat Agent ---
	var e11 := EncounterDef.new()
	e11.id = "lapa_technocrat_agent"
	e11.title = "Technocracy Agent in Lapa"
	e11.description = "A Technocracy operative has been spotted gathering intelligence in Lapa. They seem to be alone."
	e11.location_id = "lapa"
	e11.encounter_type = Enums.EncounterType.COMBAT
	e11.difficulty = 3
	e11.resolution_stat = "wits"
	e11.success_xp = 80
	e11.failure_xp = 15
	e11.dilemma_text = "The Technocracy agent is vulnerable. How do you approach?"
	e11.dilemma_options = [
		{
			"text": "Confront directly with force",
			"stat": "strength",
			"difficulty": 4,
			"cosmic_impact": {"destruction": 0.05, "creation": -0.02},
			"narrative": "{mago_name} confronted the Technocrat with overwhelming force at {location}."
		},
		{
			"text": "Outthink and trap them",
			"stat": "wits",
			"difficulty": 3,
			"cosmic_impact": {"conservation": 0.03},
			"narrative": "{mago_name} devised a cunning trap, capturing the Technocrat and extracting intelligence."
		},
		{
			"text": "Attempt diplomatic contact",
			"stat": "charisma",
			"difficulty": 5,
			"cosmic_impact": {"conservation": 0.06, "destruction": -0.04},
			"narrative": "{mago_name} opened a dialogue with the Technocrat, seeking common ground."
		}
	]
	e11.spawn_chance = 0.05
	encounters.append(e11)

	# =============================================
	# FIND NODE ENCOUNTERS
	# =============================================

	var e13 := EncounterDef.new()
	e13.id = "centro_node_discovery"
	e13.title = "Hidden Node in Centro"
	e13.description = "A previously unknown Node of Quintessence has been detected beneath an old church in Centro."
	e13.location_id = "centro"
	e13.encounter_type = Enums.EncounterType.FIND_NODE
	e13.difficulty = 3
	e13.resolution_stat = "perception"
	e13.success_xp = 120
	e13.failure_xp = 25
	e13.success_narrative = "{mago_name} perceived the hidden Node and attuned to its Quintessence for the Kabbalah."
	e13.failure_narrative = "{mago_name} sensed something but couldn't pinpoint the Node's location."
	e13.cosmic_impact = {"creation": 0.06, "conservation": 0.03}
	e13.spawn_chance = 0.04
	encounters.append(e13)

	var e19 := EncounterDef.new()
	e19.id = "santa_teresa_resonance"
	e19.title = "Resonance Harmonics"
	e19.description = "The artistic energy of Santa Teresa has created a resonance harmonic — reality sings in tune with human creativity. A Node may form."
	e19.location_id = "santa_teresa"
	e19.encounter_type = Enums.EncounterType.FIND_NODE
	e19.difficulty = 2
	e19.resolution_stat = "perception"
	e19.success_xp = 80
	e19.failure_xp = 15
	e19.success_narrative = "{mago_name} attuned to the resonance harmonic, crystallizing it into a permanent Node."
	e19.failure_narrative = "{mago_name} could hear the harmonic but couldn't anchor the Node's formation."
	e19.cosmic_impact = {"creation": 0.04, "conservation": 0.02}
	e19.spawn_chance = 0.07
	encounters.append(e19)

	var e25 := EncounterDef.new()
	e25.id = "tijuca_primal_wellspring"
	e25.title = "Primal Wellspring"
	e25.description = "Deep in the Tijuca Forest, an ancient wellspring of raw Quintessence bubbles to the surface."
	e25.location_id = "tijuca"
	e25.encounter_type = Enums.EncounterType.FIND_NODE
	e25.difficulty = 4
	e25.resolution_stat = "perception"
	e25.success_xp = 110
	e25.failure_xp = 20
	e25.success_narrative = "{mago_name} discovered the primal wellspring and secured it as a Node for the Kabbalah."
	e25.failure_narrative = "{mago_name} sensed the wellspring but the jungle's spirits drove them away."
	e25.cosmic_impact = {"creation": 0.05, "conservation": 0.02}
	e25.spawn_chance = 0.04
	encounters.append(e25)

	# =============================================
	# COSMIC BALANCE ENCOUNTERS
	# =============================================

	var e14 := EncounterDef.new()
	e14.id = "tijuca_spirit_guardian"
	e14.title = "Spirit Guardian of Tijuca"
	e14.description = "An ancient spirit guardian of the Tijuca Forest offers wisdom on restoring the cosmic balance."
	e14.location_id = "tijuca"
	e14.encounter_type = Enums.EncounterType.COSMIC_BALANCE
	e14.difficulty = 3
	e14.resolution_stat = "charisma"
	e14.success_xp = 75
	e14.failure_xp = 15
	e14.success_narrative = "{mago_name} won the spirit guardian's favor, receiving wisdom to restore cosmic harmony."
	e14.failure_narrative = "{mago_name} offended the spirit guardian. The cosmic imbalance persists."
	e14.cosmic_impact = {"conservation": 0.08, "destruction": -0.04, "creation": -0.02}
	e14.spawn_chance = 0.06
	encounters.append(e14)

	var e17 := EncounterDef.new()
	e17.id = "rocinha_marauder"
	e17.title = "Marauder Sighting"
	e17.description = "A Marauder wanders through Rocinha, their fractured Avatar warping reality. Calming them could restore balance."
	e17.location_id = "rocinha"
	e17.encounter_type = Enums.EncounterType.COSMIC_BALANCE
	e17.difficulty = 5
	e17.resolution_stat = "charisma"
	e17.success_xp = 130
	e17.failure_xp = 30
	e17.success_narrative = "{mago_name} reached the Marauder with compassion, stabilizing reality and restoring cosmic balance."
	e17.failure_narrative = "{mago_name} could not reach the Marauder. Reality continues to fracture in their wake."
	e17.cosmic_impact = {"creation": -0.05, "destruction": -0.05, "conservation": 0.10}
	e17.spawn_chance = 0.03
	encounters.append(e17)

	var e18 := EncounterDef.new()
	e18.id = "pao_de_acucar_gauntlet"
	e18.title = "Gauntlet Rift"
	e18.description = "A rift in the Gauntlet at Pao de Acucar destabilizes the cosmic balance. Sealing it requires great focus."
	e18.location_id = "pao_de_acucar"
	e18.encounter_type = Enums.EncounterType.COSMIC_BALANCE
	e18.difficulty = 4
	e18.resolution_stat = "intelligence"
	e18.success_xp = 90
	e18.failure_xp = 20
	e18.success_narrative = "{mago_name} devised a method to seal the Gauntlet rift, restoring balance between worlds."
	e18.failure_narrative = "{mago_name} couldn't seal the rift. Spirits continue to slip through."
	e18.cosmic_impact = {"conservation": 0.07, "destruction": -0.04}
	e18.spawn_chance = 0.05
	encounters.append(e18)

	var e20 := EncounterDef.new()
	e20.id = "corcovado_umbral_gate"
	e20.title = "Umbral Gate at Corcovado"
	e20.description = "An ancient Umbral gate beneath Corcovado has activated, destabilizing the cosmic balance."
	e20.location_id = "corcovado"
	e20.encounter_type = Enums.EncounterType.COSMIC_BALANCE
	e20.difficulty = 5
	e20.resolution_stat = "intelligence"
	e20.success_xp = 140
	e20.failure_xp = 35
	e20.success_narrative = "{mago_name} sealed the Umbral gate with powerful wards, restoring cosmic equilibrium."
	e20.failure_narrative = "{mago_name} was overwhelmed by the gate's power. It remains partially open."
	e20.cosmic_impact = {"conservation": 0.08, "destruction": -0.05}
	e20.spawn_chance = 0.03
	encounters.append(e20)

	# =============================================
	# RANDOM ENCOUNTERS (attribute-tested)
	# =============================================

	var e12 := EncounterDef.new()
	e12.id = "copacabana_sleeper_witness"
	e12.title = "Sleeper Witnesses"
	e12.description = "A group of Sleepers witnessed obvious magical activity on Copacabana beach. The Consensus is at risk."
	e12.location_id = "copacabana"
	e12.encounter_type = Enums.EncounterType.RANDOM
	e12.difficulty = 2
	e12.resolution_stat = "manipulation"
	e12.success_xp = 50
	e12.failure_xp = 10
	e12.success_narrative = "{mago_name} skillfully manipulated the Sleepers' perceptions, preserving the Consensus."
	e12.failure_narrative = "{mago_name} couldn't fully convince the witnesses. Rumors of strange events spread."
	e12.cosmic_impact = {"conservation": 0.02}
	e12.spawn_chance = 0.1
	encounters.append(e12)

	var e26 := EncounterDef.new()
	e26.id = "botafogo_matter_shift"
	e26.title = "Matter Transmutation"
	e26.description = "Objects in Botafogo spontaneously change material composition. Glass turns to lead, wood to stone."
	e26.location_id = "botafogo"
	e26.encounter_type = Enums.EncounterType.RANDOM
	e26.difficulty = 3
	e26.resolution_stat = "wits"
	e26.success_xp = 60
	e26.failure_xp = 15
	e26.success_narrative = "{mago_name} quickly identified the transmutation pattern and reversed it."
	e26.failure_narrative = "{mago_name} couldn't reverse all the transmutations. Some anomalies remain in Botafogo."
	e26.cosmic_impact = {"creation": -0.03, "conservation": 0.03}
	e26.spawn_chance = 0.08
	encounters.append(e26)

	var e27 := EncounterDef.new()
	e27.id = "rocinha_entropy_wave"
	e27.title = "Entropy Wave in Rocinha"
	e27.description = "An entropy wave ripples through Rocinha. Buildings decay at accelerated rates."
	e27.location_id = "rocinha"
	e27.encounter_type = Enums.EncounterType.RANDOM
	e27.difficulty = 3
	e27.resolution_stat = "stamina_attr"
	e27.success_xp = 70
	e27.failure_xp = 15
	e27.success_narrative = "{mago_name} endured the entropy wave's drain and reversed the accelerated decay."
	e27.failure_narrative = "{mago_name} could not halt the decay. Rocinha continues to deteriorate."
	e27.cosmic_impact = {"destruction": -0.04, "conservation": 0.02}
	e27.spawn_chance = 0.07
	encounters.append(e27)

	# =============================================
	# FIND MAGO ENCOUNTERS
	# =============================================

	var e16 := EncounterDef.new()
	e16.id = "ipanema_awakening"
	e16.title = "Potential Awakening"
	e16.description = "A young artist on Ipanema shows signs of Awakening. Their art bends reality around it. Guide them to join the Kabbalah."
	e16.location_id = "ipanema"
	e16.encounter_type = Enums.EncounterType.FIND_MAGO
	e16.difficulty = 3
	e16.resolution_stat = "charisma"
	e16.success_xp = 100
	e16.failure_xp = 20
	e16.success_narrative = "{mago_name} guided the young artist through their Awakening. {recruited_mago} joins the Kabbalah!"
	e16.failure_narrative = "{mago_name} tried to help but the moment passed. The artist's potential fades."
	e16.cosmic_impact = {"creation": 0.05, "conservation": 0.02}
	e16.spawn_chance = 0.04
	e16.cooldown_minutes = 1200.0
	e16.reward_mago = {
		"mago_name": "Daniela",
		"tradition": "Cult of Ecstasy",
		"arete": 1,
		"attributes": {"charisma": 3, "appearance": 4, "perception": 3, "dexterity": 2},
		"spheres": {"time_sphere": 1, "mind": 1}
	}
	encounters.append(e16)

	var e22 := EncounterDef.new()
	e22.id = "santa_teresa_hermit_mage"
	e22.title = "The Hermit of Santa Teresa"
	e22.description = "An elderly hermit in Santa Teresa is said to possess great wisdom. Convince them to join your cause."
	e22.location_id = "santa_teresa"
	e22.encounter_type = Enums.EncounterType.FIND_MAGO
	e22.difficulty = 4
	e22.resolution_stat = "manipulation"
	e22.success_xp = 110
	e22.failure_xp = 25
	e22.success_narrative = "{mago_name} persuaded the hermit to emerge from seclusion. {recruited_mago} joins the Kabbalah!"
	e22.failure_narrative = "{mago_name} could not convince the hermit. They retreated further into solitude."
	e22.cosmic_impact = {"conservation": 0.03}
	e22.spawn_chance = 0.03
	e22.cooldown_minutes = 1200.0
	e22.reward_mago = {
		"mago_name": "Tiago",
		"tradition": "Euthanatos",
		"arete": 2,
		"attributes": {"intelligence": 4, "wits": 3, "perception": 3, "stamina_attr": 2},
		"spheres": {"entropy": 2, "life": 1, "spirit": 1}
	}
	encounters.append(e22)

	var e23 := EncounterDef.new()
	e23.id = "corcovado_wandering_mage"
	e23.title = "Wandering Mage at Corcovado"
	e23.description = "A solitary mage meditates at Corcovado's summit, seeking purpose. They may be receptive to joining a Kabbalah."
	e23.location_id = "corcovado"
	e23.encounter_type = Enums.EncounterType.FIND_MAGO
	e23.difficulty = 3
	e23.resolution_stat = "charisma"
	e23.success_xp = 90
	e23.failure_xp = 20
	e23.success_narrative = "{mago_name} connected with the wandering mage's spirit. {recruited_mago} joins the Kabbalah!"
	e23.failure_narrative = "{mago_name} spoke with the mage but they chose to continue their solitary path."
	e23.cosmic_impact = {"creation": 0.03, "conservation": 0.02}
	e23.spawn_chance = 0.03
	e23.cooldown_minutes = 1200.0
	e23.reward_mago = {
		"mago_name": "Fernanda",
		"tradition": "Celestial Chorus",
		"arete": 1,
		"attributes": {"charisma": 4, "manipulation": 2, "appearance": 3, "stamina_attr": 2},
		"spheres": {"prime": 2, "spirit": 1}
	}
	encounters.append(e23)

	return encounters


func _on_location_clicked(location_id: String) -> void:
	# Check for encounters at this location (only fires when no mago is selected)
	var mago_present := false
	for mago in PartyManager.magos:
		if mago.current_location == location_id and not mago.is_traveling:
			mago_present = true
			break

	if mago_present and EncounterManager.has_encounter_at(location_id):
		var enc_def: EncounterDef = EncounterManager.get_encounter_at(location_id)
		encounter_panel.show_encounter(enc_def)


func _on_encounter_spawned(enc_def: EncounterDef, location_id: String) -> void:
	# Already handled by rio_map for visual markers
	pass


func _on_mago_ascended(mago: MagoStats) -> void:
	# Check if cosmic crisis should be resolved
	if CosmicBalance.is_in_crisis():
		CosmicBalance.resolve_crisis()

	# Victory!
	GameClock.pause_game()
	_show_victory(mago)


func _show_victory(mago: MagoStats) -> void:
	var victory_panel := PanelContainer.new()
	victory_panel.anchors_preset = Control.PRESET_CENTER
	victory_panel.custom_minimum_size = Vector2(600, 400)

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	victory_panel.add_child(vbox)

	var title := Label.new()
	title.text = "ASCENSION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 48)
	title.modulate = Color.GOLD
	vbox.add_child(title)

	var body := Label.new()
	body.text = "%s has achieved Arete 10 and Ascended!\nThe Kabbalah's journey reaches its ultimate culmination.\nThe cosmic balance is restored." % mago.mago_name
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	body.autowrap_mode = TextServer.AUTOWRAP_WORD
	vbox.add_child(body)

	var time_label := Label.new()
	time_label.text = "Time: %s" % GameClock.get_time_string()
	time_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	time_label.modulate = Color(0.7, 0.7, 0.7)
	vbox.add_child(time_label)

	# Add to FX layer or popup layer
	var popup_layer = get_node_or_null("PopupLayer")
	if popup_layer:
		popup_layer.add_child(victory_panel)
	else:
		add_child(victory_panel)
