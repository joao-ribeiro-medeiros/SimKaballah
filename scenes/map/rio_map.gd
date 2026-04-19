extends Node2D

# Location graph: location_id -> {name, position, connections}
var locations: Dictionary = {}
var _party_token: Node2D = null

@onready var locations_node: Node2D = $Locations
@onready var encounter_markers_node: Node2D = $EncounterMarkers
@onready var party_tokens_node: Node2D = $PartyTokens


func _ready() -> void:
	_build_location_graph()
	SignalBus.encounter_spawned.connect(_on_encounter_spawned)
	SignalBus.encounter_resolved.connect(_on_encounter_resolved)
	SignalBus.party_moved.connect(_on_party_moved)
	SignalBus.party_arrived.connect(_on_party_arrived)
	_spawn_party_token()


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


func _spawn_party_token() -> void:
	var token_scene := preload("res://scenes/map/mago_token.tscn")
	_party_token = token_scene.instantiate()
	party_tokens_node.add_child(_party_token)
	var start_pos := get_location_position(PartyManager.current_location)
	_party_token.global_position = start_pos


func _on_party_moved(destination_id: String) -> void:
	if _party_token == null:
		return
	var path := find_path(PartyManager.current_location, destination_id)
	if path.is_empty():
		return
	PartyManager.move_to(path)
	_animate_travel(path)


func _animate_travel(path: Array[String]) -> void:
	if _party_token == null:
		return
	var tween := create_tween()
	for loc_id in path:
		var target := get_location_position(loc_id)
		tween.tween_property(_party_token, "global_position", target, 0.5)


func _on_party_arrived(location_id: String) -> void:
	if _party_token:
		_party_token.global_position = get_location_position(location_id)


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
