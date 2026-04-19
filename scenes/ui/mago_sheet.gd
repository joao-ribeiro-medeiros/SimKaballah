extends PopupPanel

var current_mago: MagoStats = null

@onready var name_label: Label = %MagoName
@onready var tradition_label: Label = %TraditionLabel
@onready var arete_label: Label = %AreteLabel
@onready var xp_label: Label = %XPLabel
@onready var health_label: Label = %HealthLabel
@onready var stamina_label: Label = %StaminaLabel
@onready var paradox_label: Label = %ParadoxLabel

# Attributes
@onready var strength_label: Label = %StrengthLabel
@onready var dexterity_label: Label = %DexterityLabel
@onready var stamina_attr_label: Label = %StaminaAttrLabel
@onready var charisma_label: Label = %CharismaLabel
@onready var manipulation_label: Label = %ManipulationLabel
@onready var appearance_label: Label = %AppearanceLabel
@onready var intelligence_label: Label = %IntelligenceLabel
@onready var wits_label: Label = %WitsLabel
@onready var perception_label: Label = %PerceptionLabel

# Spheres
@onready var spheres_container: VBoxContainer = %SpheresContainer

# Advancement buttons
@onready var advance_arete_btn: Button = %AdvanceAreteBtn

func _ready() -> void:
	add_to_group("mago_sheet")
	SignalBus.mago_stat_changed.connect(_on_mago_stat_changed)
	if advance_arete_btn:
		advance_arete_btn.pressed.connect(_on_advance_arete)


func show_mago(mago: MagoStats) -> void:
	current_mago = mago
	_refresh()
	popup_centered(Vector2i(500, 700))


func _refresh() -> void:
	if current_mago == null:
		return
	var m := current_mago

	name_label.text = m.mago_name
	tradition_label.text = m.tradition
	arete_label.text = "Arete: %d / 10" % m.arete
	xp_label.text = "XP: %d" % m.experience
	health_label.text = "Health: %s" % Enums.Health.keys()[m.health]
	stamina_label.text = "Stamina: %s" % Enums.Stamina.keys()[m.stamina]
	paradox_label.text = "Paradox: %s" % Enums.Paradox.keys()[m.paradox]

	# Attributes
	strength_label.text = "Strength: %d" % m.strength
	dexterity_label.text = "Dexterity: %d" % m.dexterity
	stamina_attr_label.text = "Stamina: %d" % m.stamina_attr
	charisma_label.text = "Charisma: %d" % m.charisma
	manipulation_label.text = "Manipulation: %d" % m.manipulation
	appearance_label.text = "Appearance: %d" % m.appearance
	intelligence_label.text = "Intelligence: %d" % m.intelligence
	wits_label.text = "Wits: %d" % m.wits
	perception_label.text = "Perception: %d" % m.perception

	# Spheres
	_refresh_spheres()

	# Advancement button
	if advance_arete_btn:
		var cost := m.arete_advance_cost()
		advance_arete_btn.text = "Advance Arete (%d XP)" % cost
		advance_arete_btn.disabled = m.experience < cost or m.arete >= 10


func _refresh_spheres() -> void:
	if spheres_container == null:
		return
	for child in spheres_container.get_children():
		child.queue_free()

	var m := current_mago
	for sphere_name in m.get_all_sphere_names():
		var hbox := HBoxContainer.new()

		var display_name := sphere_name.replace("_", " ").capitalize()
		var label := Label.new()
		label.text = "%s: %d" % [display_name, m.get_sphere(sphere_name)]
		label.custom_minimum_size.x = 180
		hbox.add_child(label)

		var dots := Label.new()
		var val := m.get_sphere(sphere_name)
		dots.text = "●".repeat(val) + "○".repeat(5 - val)
		hbox.add_child(dots)

		var advance_btn := Button.new()
		var cost := m.sphere_advance_cost(sphere_name)
		advance_btn.text = "+(%d XP)" % cost
		advance_btn.disabled = m.experience < cost or val >= 5
		advance_btn.custom_minimum_size = Vector2(90, 0)
		var sn := sphere_name # capture
		advance_btn.pressed.connect(func(): _on_advance_sphere(sn))
		hbox.add_child(advance_btn)

		spheres_container.add_child(hbox)


func _on_advance_arete() -> void:
	if current_mago:
		PartyManager.try_advance_arete(current_mago)
		_refresh()


func _on_advance_sphere(sphere_name: String) -> void:
	if current_mago:
		PartyManager.try_advance_sphere(current_mago, sphere_name)
		_refresh()


func _on_mago_stat_changed(mago: MagoStats, _stat: String, _old, _new) -> void:
	if mago == current_mago and visible:
		_refresh()
