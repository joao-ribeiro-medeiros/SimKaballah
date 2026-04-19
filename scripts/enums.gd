class_name Enums

enum Stamina {
	INCAPACITATED,
	TIRED,
	READY
}

enum Health {
	READY,
	HURT,
	GRAVELY_WOUNDED
}

enum Paradox {
	NONE,
	LOW,
	MEDIUM,
	HIGH
}

enum EncounterType {
	STORY,
	RANDOM,
	COSMIC,
	COMBAT,
	FIND_NODE,
	COSMIC_BALANCE,
	FIND_MAGO
}

enum CosmicTendency {
	CREATION,
	DESTRUCTION,
	CONSERVATION
}

enum TimeScale {
	PAUSED = 0,
	NORMAL = 1,
	FAST = 2,
	FASTER = 4,
	FASTEST = 8
}
