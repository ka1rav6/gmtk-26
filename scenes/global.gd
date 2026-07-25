extends Node


var score: int
var powerMode: bool
var player: CharacterBody2D
var throwDistance: int
var enemy_count :=0
var kill_count := 0
const ULTRAINSTINCT_SLOWDOWN = 0.1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	powerMode = false
	refresh_player()
	throwDistance = 150

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if not is_instance_valid(player):
		refresh_player()

func refresh_player() -> void:
	if not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("Player")

# Resets every piece of persistent state Global tracks. Scene-local state
# (player, enemies, collectibles, timers, etc.) lives in the level scene
# itself, so reloading/swapping that scene resets it for free — this only
# has to clean up what actually survives a scene change.
func reset_state() -> void:
	score = 0
	powerMode = false
	enemy_count = 0
	kill_count = 0
	player = null

# Used by both the start menu and the pause menu so "Start" and "Restart"
# never fall out of sync with each other.
func start_level(level_scene: PackedScene) -> void:
	reset_state()
	get_tree().paused = false
	get_tree().change_scene_to_packed(level_scene)

# Restarts whatever level is currently running, fresh, regardless of
# whether it's paused or the player has already died.
func restart_current_level() -> void:
	reset_state()
	get_tree().paused = false
	get_tree().reload_current_scene()
		
func toggle_all() -> void:
	refresh_player()
	powerMode = !powerMode
	if is_instance_valid(player):
		player.bgm.visible = powerMode
		if powerMode:
			player.velocity *= ULTRAINSTINCT_SLOWDOWN
		player.currentTimeFactor = ULTRAINSTINCT_SLOWDOWN if powerMode else 1.0
	var nodes = get_tree().get_nodes_in_group("selectable")
	for node in nodes:
		if not is_instance_valid(node):
			continue
		if node.has_method("toggle_sprite"):
			node.toggle_sprite()
		if "currentTimeFactor" in node:
			if "isAffectedBy" in node and node.isAffectedBy > 0:
				continue
			if powerMode and "velocity" in node:
				node.velocity *= ULTRAINSTINCT_SLOWDOWN
			node.currentTimeFactor = ULTRAINSTINCT_SLOWDOWN if powerMode else 1.0
