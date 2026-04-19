extends PanelContainer

@onready var title_label: Label = %EncounterTitle
@onready var description_label: RichTextLabel = %EncounterDescription
@onready var difficulty_label: Label = %DifficultyLabel
@onready var stat_label: Label = %StatLabel
@onready var probability_label: Label = %ProbabilityLabel
@onready var slots_container: HBoxContainer = %DeploymentSlots
@onready var available_list: VBoxContainer = %AvailableList
@onready var dilemma_container: VBoxContainer = %DilemmaContainer
@onready var engage_btn: Button = %EngageBtn
@onready var withdraw_btn: Button = %WithdrawBtn

var current_encounter: EncounterDef = null
var assigned_magos: Array[MagoStats] = []
var selected_dilemma: int = -1

const MAX_DEPLOY := 3
var _deployment_slot_script := preload("res://scenes/encounters/deployment_slot.gd")


func _ready() -> void:
	engage_btn.pressed.connect(_on_engage)
	withdraw_btn.pressed.connect(_on_withdraw)
	hide()


func show_encounter(enc_def: EncounterDef) -> void:
	current_encounter = enc_def
	assigned_magos.clear()
	selected_dilemma = -1

	title_label.text = enc_def.title
	description_label.text = enc_def.description
	difficulty_label.text = "Difficulty: %d" % enc_def.difficulty
	stat_label.text = "Requires: %s" % enc_def.resolution_stat.capitalize()

	_build_available_list()
	_build_deployment_slots()
	_build_dilemma()
	_update_probability()

	show()
	# Slow time during encounter
	GameClock.set_time_scale(0.0)


func _build_available_list() -> void:
	for child in available_list.get_children():
		child.queue_free()

	var available := PartyManager.get_available_magos()
	for mago in available:
		var btn := Button.new()
		var skill := mago.get_stat(current_encounter.resolution_stat)
		btn.text = "%s (%s: %d)" % [mago.mago_name, current_encounter.resolution_stat.capitalize(), skill]
		btn.pressed.connect(func(): _assign_mago(mago))
		btn.set_meta("mago_name", mago.mago_name)
		available_list.add_child(btn)


func _build_deployment_slots() -> void:
	for child in slots_container.get_children():
		child.queue_free()

	for i in range(MAX_DEPLOY):
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(120, 60)
		slot.set_script(_deployment_slot_script)
		slot.mago_dropped.connect(func(mago: MagoStats): _assign_mago(mago))

		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if i < assigned_magos.size():
			label.text = assigned_magos[i].mago_name
			# Click to unassign
			var idx := i
			slot.gui_input.connect(func(event: InputEvent):
				if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
					_unassign_mago(idx)
			)
		else:
			label.text = "[Drop Mago Here]"
			label.modulate = Color(0.5, 0.5, 0.5)

		slot.add_child(label)
		slots_container.add_child(slot)


func _build_dilemma() -> void:
	for child in dilemma_container.get_children():
		child.queue_free()

	if current_encounter.dilemma_text.is_empty():
		dilemma_container.hide()
		return

	dilemma_container.show()

	var dilemma_label := RichTextLabel.new()
	dilemma_label.bbcode_enabled = true
	dilemma_label.fit_content = true
	dilemma_label.text = current_encounter.dilemma_text
	dilemma_container.add_child(dilemma_label)

	for i in range(current_encounter.dilemma_options.size()):
		var option: Dictionary = current_encounter.dilemma_options[i]
		var btn := Button.new()
		btn.text = option.get("text", "Option %d" % (i + 1))
		btn.toggle_mode = true
		btn.button_pressed = (selected_dilemma == i)
		var idx := i
		btn.pressed.connect(func():
			selected_dilemma = idx
			_update_probability()
		)
		dilemma_container.add_child(btn)


func _assign_mago(mago: MagoStats) -> void:
	if assigned_magos.size() >= MAX_DEPLOY:
		return
	if mago in assigned_magos:
		return
	assigned_magos.append(mago)
	_build_deployment_slots()
	_build_available_list()
	_update_probability()


func _unassign_mago(index: int) -> void:
	if index < assigned_magos.size():
		assigned_magos.remove_at(index)
		_build_deployment_slots()
		_build_available_list()
		_update_probability()


func _update_probability() -> void:
	if assigned_magos.is_empty():
		probability_label.text = "Deploy Magos to see chances"
		engage_btn.disabled = true
		return

	var stat_name := current_encounter.resolution_stat
	var difficulty := current_encounter.difficulty

	if selected_dilemma >= 0 and selected_dilemma < current_encounter.dilemma_options.size():
		var option: Dictionary = current_encounter.dilemma_options[selected_dilemma]
		stat_name = option.get("stat", stat_name)
		difficulty = option.get("difficulty", difficulty)

	var result := TrialResolver.find_best_resolver(assigned_magos, stat_name)
	var best_mago: MagoStats = result[0]
	var best_skill: int = result[1]
	var prob := TrialResolver.get_probability(best_skill, difficulty)

	probability_label.text = "Best: %s (%s %d) | %d%% chance" % [
		best_mago.mago_name if best_mago else "None",
		stat_name.capitalize(),
		best_skill,
		int(prob * 100)
	]

	if prob >= 1.0:
		probability_label.modulate = Color.GREEN
	elif prob >= 0.5:
		probability_label.modulate = Color.YELLOW
	else:
		probability_label.modulate = Color.RED

	engage_btn.disabled = false


func _on_engage() -> void:
	if current_encounter == null or assigned_magos.is_empty():
		return

	# Deploy magos
	var names: Array[String] = []
	for m in assigned_magos:
		names.append(m.mago_name)
	PartyManager.deploy_to_encounter(names)

	# Resolve
	var outcome := EncounterManager.resolve_encounter(current_encounter, assigned_magos, selected_dilemma)

	# Release magos
	PartyManager.release_from_encounter(names)

	# Show result briefly
	_show_result(outcome)


func _on_withdraw() -> void:
	_close()


func _show_result(outcome: EncounterOutcome) -> void:
	title_label.text = "SUCCESS!" if outcome.success else "FAILURE"
	title_label.modulate = Color.GREEN if outcome.success else Color.RED
	description_label.text = outcome.narrative
	probability_label.text = "XP Awarded: %d" % outcome.xp_awarded

	engage_btn.hide()
	withdraw_btn.text = "Continue"
	withdraw_btn.pressed.disconnect(_on_withdraw)
	withdraw_btn.pressed.connect(_close)

	# Hide deployment UI
	slots_container.hide()
	available_list.hide()
	dilemma_container.hide()


func _close() -> void:
	hide()
	current_encounter = null
	assigned_magos.clear()

	# Reset UI state
	engage_btn.show()
	withdraw_btn.text = "Withdraw"
	slots_container.show()
	available_list.show()

	# Reconnect withdraw
	if withdraw_btn.pressed.is_connected(_close):
		withdraw_btn.pressed.disconnect(_close)
	if not withdraw_btn.pressed.is_connected(_on_withdraw):
		withdraw_btn.pressed.connect(_on_withdraw)

	title_label.modulate = Color.WHITE

	# Resume time
	GameClock.set_time_scale(1.0)
