extends CharacterBody2D


@export var SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export var MAX_HEALTH := 25
var health: int

@export var COUNTDOWN_HEIGHT := 25
var cd_height: int

var tmrScene: PackedScene

@onready var currentTimeFactor := 1.0

var player: CharacterBody2D

func _ready() -> void:
	tmrScene = preload("res://scenes/characters/timer_node.tscn")
	health = MAX_HEALTH
	await  get_tree().process_frame
	player = get_tree().get_first_node_in_group("Player")


func CreateTimer(time: int, functi: Callable):
	var x = tmrScene.instantiate()
	x.time = time
	x.cb = functi 
	x.height = cd_height
	add_child(x)
