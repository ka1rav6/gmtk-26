extends Node

var score: int
var powerMode: bool
var player: CharacterBody2D

const ULTRAINSTINCT_SLOWDOWN = 0.25

func toggle_all() -> void:
	refresh_player()
	powerMode = !powerMode
	if is_instance_valid(player):
		player.bgm.visible = powerMode
		if powerMode:
			player.set_speed(ULTRAINSTINCT_SLOWDOWN)
		else:
			player.set_speed(1 / ULTRAINSTINCT_SLOWDOWN)
	var nodes = get_tree().get_nodes_in_group("selectable")
	for node in nodes:
		if not is_instance_valid(node):
			continue
		if node.has_method("toggle_sprite"):
			node.toggle_sprite()
		if node.has_method("set_speed"):
			if powerMode:
				node.set_speed(ULTRAINSTINCT_SLOWDOWN)
			else:
				node.set_speed(1 / ULTRAINSTINCT_SLOWDOWN)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score = 0
	powerMode = false
	refresh_player()
	

func refresh_player() -> void:
	if not is_instance_valid(player):
		player = null
		await  get_tree().process_frame
		player = get_tree().get_first_node_in_group("Player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
