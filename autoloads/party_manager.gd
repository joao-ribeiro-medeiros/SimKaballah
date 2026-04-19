extends Node

const MAX_PARTY_SIZE := 7

var magos: Array[MagoStats] = []
var formation: Array[String] = [] # ordered by position: 0-2 front, 3-6 back
var current_location: String = "copacabana"
var travel_path: Array[String] = []
var _travel_progress: float = 0.0
var travel_time_per_leg: float = 30.0 # game minutes per leg
var is_traveling: bool = false


func _ready() -> void:
	SignalBus.time_tick.connect(_on_time_tick)


func _on_time_tick(delta_game_seconds: float) -> void:
	if not is_traveling or travel_path.is_empty():
		return

	_travel_progress += delta_game_seconds / 60.0 # convert to minutes
	if _travel_progress >= travel_time_per_leg:
		_travel_progress = 0.0
		current_location = travel_path[0]
		travel_path.remove_at(0)
		if travel_path.is_empty():
			is_traveling = false
			SignalBus.party_arrived.emit(current_location)
		else:
			# Intermediate arrival
			pass


func move_to(path: Array[String]) -> void:
	if path.is_empty():
		return
	travel_path = path
	_travel_progress = 0.0
	is_traveling = true
	SignalBus.party_moved.emit(path[-1])


func add_mago(mago: MagoStats) -> bool:
	if magos.size() >= MAX_PARTY_SIZE:
		return false
	magos.append(mago)
	formation.append(mago.mago_name)
	return true


func remove_mago(mago_name: String) -> void:
	for i in range(magos.size()):
		if magos[i].mago_name == mago_name:
			magos.remove_at(i)
			break
	formation.erase(mago_name)


func get_mago(mago_name: String) -> MagoStats:
	for m in magos:
		if m.mago_name == mago_name:
			return m
	return null


func get_available_magos() -> Array[MagoStats]:
	var available: Array[MagoStats] = []
	for m in magos:
		if m.is_available():
			available.append(m)
	return available


func deploy_to_encounter(names: Array[String]) -> Array[MagoStats]:
	var deployed: Array[MagoStats] = []
	for n in names:
		var m := get_mago(n)
		if m and m.is_available():
			m.is_deployed = true
			deployed.append(m)
	return deployed


func release_from_encounter(names: Array[String]) -> void:
	for n in names:
		var m := get_mago(n)
		if m:
			m.is_deployed = false


func is_front_row(mago_name: String) -> bool:
	var idx := formation.find(mago_name)
	return idx >= 0 and idx < 3


func set_formation(new_order: Array[String]) -> void:
	formation = new_order


func try_advance_arete(mago: MagoStats) -> bool:
	if mago.arete >= 10:
		return false
	var cost := mago.arete_advance_cost()
	if mago.experience < cost:
		return false
	var success := TrialResolver.resolve(mago.arete, mago.arete + 1)
	if success:
		var old_arete := mago.arete
		mago.experience -= cost
		mago.arete += 1
		SignalBus.mago_stat_changed.emit(mago, "arete", old_arete, mago.arete)
		SignalBus.mago_stat_changed.emit(mago, "experience", mago.experience + cost, mago.experience)
		if mago.arete >= 10:
			SignalBus.mago_ascended.emit(mago)
		return true
	else:
		# XP still spent on failed attempt
		mago.experience -= cost
		SignalBus.mago_stat_changed.emit(mago, "experience", mago.experience + cost, mago.experience)
		return false


func try_advance_sphere(mago: MagoStats, sphere_name: String) -> bool:
	var current := mago.get_sphere(sphere_name)
	if current >= 5:
		return false
	var cost := mago.sphere_advance_cost(sphere_name)
	if mago.experience < cost:
		return false
	var old_val := current
	mago.experience -= cost
	mago.set_sphere(sphere_name, current + 1)
	SignalBus.mago_stat_changed.emit(mago, sphere_name, old_val, current + 1)
	SignalBus.mago_stat_changed.emit(mago, "experience", mago.experience + cost, mago.experience)
	return true
