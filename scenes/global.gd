extends Node

var score: int
var powerMode: bool
var player: CharacterBody2D

func toggle_all() -> void:
	refresh_player()
	powerMode = !powerMode
	player.bgm.visible = powerMode
	var nodes = get_tree().get_nodes_in_group("selectable")
	for node in nodes:
		if node.has_method("toggle_sprite"):
			node.toggle_sprite()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	powerMode = false
	refresh_player()
	

func refresh_player() -> void:
	if not player:
		await  get_tree().process_frame
		player = get_tree().get_first_node_in_group("Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
