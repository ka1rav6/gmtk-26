extends CanvasLayer

@onready var hp_bar: ProgressBar = $MarginContainer/VBoxContainer/HPRow/HPBar
@onready var hp_label: Label = $MarginContainer/VBoxContainer/HPRow/HPLabel
@onready var elixir_bar: ProgressBar = $MarginContainer/VBoxContainer/ElixirRow/ElixirBar
@onready var elixir_label: Label = $MarginContainer/VBoxContainer/ElixirRow/ElixirLabel
@onready var enemies_label: Label = $MarginContainer/VBoxContainer/EnemiesRow/EnemiesLabel

func _process(_delta: float) -> void:
	var player = Global.player
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")
		if not is_instance_valid(player):
			return
	
	hp_bar.max_value = player.MAX_HEALTH
	hp_bar.value = player.health
	hp_label.text = "%d / %d" % [player.health, player.MAX_HEALTH]
	
	elixir_bar.max_value = Global.max_elixir
	elixir_bar.value = Global.elixir
	elixir_label.text = "%d / %d" % [int(Global.elixir), int(Global.max_elixir)]
	
	var red_portal = _find_red_portal()
	if red_portal:
		var needed = max(0, red_portal.enemies_required - Global.kill_count)
		enemies_label.text = "Enemies needed: %d" % needed
		enemies_label.visible = true
	else:
		enemies_label.text = "get to the portal, fast."
		enemies_label.visible = true

func _find_red_portal() -> Node:
	for p in get_tree().get_nodes_in_group("locked_portal"):
		if is_instance_valid(p) and "enemies_required" in p and Global.kill_count < p.enemies_required:
			return p
	return null
