class_name TrialResolver

## Resolves a skill check.
## skill >= difficulty → automatic success
## skill < difficulty → probability = skill / difficulty
## Returns true on success.
static func resolve(skill: int, difficulty: int) -> bool:
	if difficulty <= 0:
		return true
	if skill >= difficulty:
		return true
	if skill <= 0:
		return false
	var probability := float(skill) / float(difficulty)
	return randf() < probability


## Returns the success probability (0.0 to 1.0).
static func get_probability(skill: int, difficulty: int) -> float:
	if difficulty <= 0:
		return 1.0
	if skill >= difficulty:
		return 1.0
	if skill <= 0:
		return 0.0
	return float(skill) / float(difficulty)


## Finds the best mago for a given stat among deployed magos.
## Returns [best_mago, effective_skill].
## Accounts for relationship bonuses between co-deployed magos.
static func find_best_resolver(magos: Array, stat_name: String) -> Array:
	if magos.is_empty():
		return [null, 0]

	var best_mago = null
	var best_skill := 0

	for mago in magos:
		var base_skill: int = mago.get_stat(stat_name)
		var bonus := _relationship_bonus(mago, magos)
		var effective := base_skill + bonus
		if effective > best_skill:
			best_skill = effective
			best_mago = mago

	return [best_mago, best_skill]


## +1 bonus if any co-deployed mago has bond >= +3
static func _relationship_bonus(mago: MagoStats, all_deployed: Array) -> int:
	for other in all_deployed:
		if other == mago:
			continue
		if mago.get_relationship(other.mago_name) >= 3:
			return 1
	return 0
