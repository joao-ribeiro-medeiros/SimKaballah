extends Node2D

var locations: Dictionary = {}
var _mago_tokens: Dictionary = {} # mago_name -> Node2D
var _selected_mago: MagoStats = null
var _active_tweens: Dictionary = {} # mago_name -> Tween

@onready var locations_node: Node2D = $Locations
@onready var encounter_markers_node: Node2D = $EncounterMarkers
@onready var party_tokens_node: Node2D = $PartyTokens


func _ready() -> void:
	_build_location_graph()
	queue_redraw()
	SignalBus.encounter_spawned.connect(_on_encounter_spawned)
	SignalBus.encounter_resolved.connect(_on_encounter_resolved)
	SignalBus.encounter_expired.connect(_on_encounter_expired)
	call_deferred("_spawn_mago_tokens")


func _input(event: InputEvent) -> void:
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return

	var canvas_xform: Transform2D = get_canvas_transform()
	var world_pos: Vector2 = canvas_xform.affine_inverse() * Vector2(event.position)

	# 1) Check if clicking on a mago token
	var clicked_token = _get_token_at(world_pos)
	if clicked_token:
		var mago: MagoStats = clicked_token.mago
		get_viewport().set_input_as_handled()
		if mago.is_traveling:
			return # can't select a traveling mago
		if _selected_mago == mago:
			_deselect()
		else:
			_select_mago(mago)
		return

	# 2) Mago selected — try to move to a location
	if _selected_mago:
		var loc_id: String = _get_location_at(world_pos, 80.0)
		if not loc_id.is_empty() and loc_id != _selected_mago.current_location:
			get_viewport().set_input_as_handled()
			_move_selected_to(loc_id)
		else:
			_deselect()
		return

	# 3) No mago selected — location click for encounters
	var loc_id: String = _get_location_at(world_pos, 80.0)
	if not loc_id.is_empty():
		SignalBus.location_clicked.emit(loc_id)


# --- Drawing ---

func _draw() -> void:
	var drawn_pairs: Dictionary = {}
	for loc_id in locations:
		var loc: Dictionary = locations[loc_id]
		for neighbor_id in loc.get("connections", []):
			var pair_key: String
			if loc_id < neighbor_id:
				pair_key = loc_id + "|" + neighbor_id
			else:
				pair_key = neighbor_id + "|" + loc_id
			if pair_key in drawn_pairs:
				continue
			drawn_pairs[pair_key] = true
			if neighbor_id in locations:
				draw_line(loc.position, locations[neighbor_id].position, Color(1, 0.85, 0.4, 0.35), 2.0, true)


# --- Location Graph ---

func _build_location_graph() -> void:
	for child in locations_node.get_children():
		if child.has_method("get_location_data"):
			var data: Dictionary = child.get_location_data()
			locations[data.id] = data


func find_path(from_id: String, to_id: String) -> Array[String]:
	if from_id == to_id or from_id not in locations or to_id not in locations:
		return []
	var queue: Array[String] = [from_id]
	var visited: Dictionary = {from_id: true}
	var parent: Dictionary = {}
	while not queue.is_empty():
		var current: String = queue.pop_front()
		if current == to_id:
			var path: Array[String] = []
			var node: String = to_id
			while node != from_id:
				path.push_front(node)
				node = parent[node]
			return path
		for neighbor in locations[current].get("connections", []):
			if neighbor not in visited:
				visited[neighbor] = true
				parent[neighbor] = current
				queue.append(neighbor)
	return []


func get_location_position(location_id: String) -> Vector2:
	if location_id in locations:
		return locations[location_id].position
	return Vector2.ZERO


# --- Hit Detection ---

func _get_token_at(world_pos: Vector2) -> Node2D:
	for mago_name in _mago_tokens:
		var token: Node2D = _mago_tokens[mago_name]
		if token.has_method("is_click_inside") and token.is_click_inside(world_pos):
			return token
	return null


func _get_location_at(world_pos: Vector2, max_dist: float = 80.0) -> String:
	var best_id: String = ""
	var best_dist: float = max_dist
	for loc_id in locations:
		var dist: float = world_pos.distance_to(locations[loc_id].position)
		if dist < best_dist:
			best_dist = dist
			best_id = loc_id
	return best_id


# --- Token Spawning ---

func _spawn_mago_tokens() -> void:
	var token_scene: PackedScene = preload("res://scenes/map/mago_token.tscn")
	var idx: int = 0
	for mago in PartyManager.magos:
		var token: Node2D = token_scene.instantiate()
		party_tokens_node.add_child(token)
		if token.has_method("setup"):
			token.setup(mago)
		var start_pos: Vector2 = get_location_position(mago.current_location)
		var offset: Vector2 = Vector2((idx - 2) * 30, 0)
		token.position = start_pos + offset
		_mago_tokens[mago.mago_name] = token
		idx += 1


func _get_mago_offset(mago_name: String) -> Vector2:
	var idx: int = 0
	for n in _mago_tokens:
		if n == mago_name:
			break
		idx += 1
	return Vector2((idx - 2) * 30, 0)


# --- Selection ---

func _select_mago(mago: MagoStats) -> void:
	_deselect()
	_selected_mago = mago
	var token = _mago_tokens.get(mago.mago_name)
	if token and token.has_method("set_selected"):
		token.set_selected(true)


func _deselect() -> void:
	if _selected_mago:
		var token = _mago_tokens.get(_selected_mago.mago_name)
		if token and token.has_method("set_selected"):
			token.set_selected(false)
		_selected_mago = null


# --- Movement ---

func _move_selected_to(location_id: String) -> void:
	var mago: MagoStats = _selected_mago
	_deselect()

	if mago.is_traveling:
		return

	var path: Array[String] = find_path(mago.current_location, location_id)
	if path.is_empty():
		return

	# Mark as traveling so they can't be selected again mid-move
	mago.is_traveling = true

	# Kill any existing tween for this mago
	if _active_tweens.has(mago.mago_name):
		var old_tween: Tween = _active_tweens[mago.mago_name]
		if old_tween and old_tween.is_valid():
			old_tween.kill()

	var token: Node2D = _mago_tokens.get(mago.mago_name)
	if not token:
		mago.is_traveling = false
		return

	var offset: Vector2 = _get_mago_offset(mago.mago_name)
	var tween: Tween = create_tween()
	_active_tweens[mago.mago_name] = tween

	for loc_id in path:
		var target: Vector2 = get_location_position(loc_id)
		tween.tween_property(token, "position", target + offset, 0.4)

	# When tween finishes, update data and check for encounters
	var final_location: String = path[-1]
	var mago_name: String = mago.mago_name
	tween.finished.connect(func():
		PartyManager.move_mago_to(mago, final_location)
		_active_tweens.erase(mago_name)
		# Auto-trigger encounter if one exists at arrival location
		if EncounterManager.has_encounter_at(final_location):
			SignalBus.location_clicked.emit(final_location)
	)


# --- Encounters ---

func _on_encounter_spawned(enc_def: EncounterDef, location_id: String) -> void:
	for child in locations_node.get_children():
		if child.has_method("get_location_data"):
			var data: Dictionary = child.get_location_data()
			if data.id == location_id:
				child.show_encounter_marker(true)
				break


func _on_encounter_expired(location_id: String) -> void:
	_clear_encounter_marker(location_id)


func _on_encounter_resolved(outcome: EncounterOutcome) -> void:
	_clear_encounter_marker(outcome.location_id)


func _clear_encounter_marker(location_id: String) -> void:
	for child in locations_node.get_children():
		if child.has_method("get_location_data"):
			var data: Dictionary = child.get_location_data()
			if data.id == location_id:
				child.show_encounter_marker(false)
				break
