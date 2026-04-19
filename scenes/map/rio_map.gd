extends Node2D

# Location graph: location_id -> {name, position, connections}
var locations: Dictionary = {}
var _mago_tokens: Dictionary = {} # mago_name -> Node2D

@onready var locations_node: Node2D = $Locations
@onready var encounter_markers_node: Node2D = $EncounterMarkers
@onready var party_tokens_node: Node2D = $PartyTokens


func _ready() -> void:
	_build_location_graph()
	queue_redraw()
	SignalBus.encounter_spawned.connect(_on_encounter_spawned)
	SignalBus.encounter_resolved.connect(_on_encounter_resolved)
	SignalBus.party_moved.connect(_on_party_moved)
	SignalBus.party_arrived.connect(_on_party_arrived)
	_spawn_mago_tokens()


func _draw() -> void:
	# Draw semi-transparent gold lines between connected locations
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
				var from_pos: Vector2 = loc.position
				var to_pos: Vector2 = locations[neighbor_id].position
				draw_line(from_pos, to_pos, Color(1, 0.85, 0.4, 0.35), 2.0, true)


func _build_location_graph() -> void:
	for child in locations_node.get_children():
		if child.has_method("get_location_data"):
			var data: Dictionary = child.get_location_data()
			locations[data.id] = data


func find_path(from_id: String, to_id: String) -> Array[String]:
	# BFS pathfinding on location graph
	if from_id == to_id:
		return []
	if from_id not in locations or to_id not in locations:
		return []

	var queue: Array[String] = [from_id]
	var visited: Dictionary = {from_id: true}
	var parent: Dictionary = {} # child -> parent

	while not queue.is_empty():
		var current: String = queue.pop_front()
		if current == to_id:
			# Reconstruct path (excluding start)
			var path: Array[String] = []
			var node := to_id
			while node != from_id:
				path.push_front(node)
				node = parent[node]
			return path

		var connections: Array = locations[current].get("connections", [])
		for neighbor in connections:
			if neighbor not in visited:
				visited[neighbor] = true
				parent[neighbor] = current
				queue.append(neighbor)

	return [] # No path found


func get_location_position(location_id: String) -> Vector2:
	if location_id in locations:
		return locations[location_id].position
	return Vector2.ZERO


func _spawn_mago_tokens() -> void:
	var token_scene := preload("res://scenes/map/mago_token.tscn")
	var start_pos := get_location_position(PartyManager.current_location)
	var idx := 0
	for mago in PartyManager.magos:
		var token: Node2D = token_scene.instantiate()
		party_tokens_node.add_child(token)
		if token.has_method("setup"):
			token.setup(mago)
		# Offset tokens so they don't overlap
		var offset := Vector2((idx - 2) * 18, 0)
		token.position = start_pos + offset
		_mago_tokens[mago.mago_name] = token
		idx += 1


func _on_party_moved(destination_id: String) -> void:
	if _mago_tokens.is_empty():
		return
	var path := find_path(PartyManager.current_location, destination_id)
	if path.is_empty():
		return
	PartyManager.move_to(path)
	_animate_travel(path)


func _animate_travel(path: Array[String]) -> void:
	if _mago_tokens.is_empty():
		return
	var idx := 0
	for mago_name in _mago_tokens:
		var token: Node2D = _mago_tokens[mago_name]
		var tween := create_tween()
		for loc_id in path:
			var target := get_location_position(loc_id)
			var offset := Vector2((idx - 2) * 18, 0)
			tween.tween_property(token, "position", target + offset, 0.5)
		idx += 1


func _on_party_arrived(location_id: String) -> void:
	var idx := 0
	for mago_name in _mago_tokens:
		var token: Node2D = _mago_tokens[mago_name]
		var offset := Vector2((idx - 2) * 18, 0)
		token.position = get_location_position(location_id) + offset
		idx += 1


func _on_encounter_spawned(enc_def: EncounterDef, location_id: String) -> void:
	# Add visual marker at location
	for child in locations_node.get_children():
		if child.has_method("get_location_data"):
			var data: Dictionary = child.get_location_data()
			if data.id == location_id:
				child.show_encounter_marker(true)
				break


func _on_encounter_resolved(outcome: EncounterOutcome) -> void:
	for child in locations_node.get_children():
		if child.has_method("get_location_data"):
			var data: Dictionary = child.get_location_data()
			if data.id == outcome.location_id:
				child.show_encounter_marker(false)
				break
