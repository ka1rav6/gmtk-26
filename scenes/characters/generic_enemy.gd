extends CharacterBody2D


@export var SPEED = 200.0
const JUMP_VELOCITY = -400.0

@export var MAX_HEALTH := 25
var health: int

@export var COUNTDOWN_HEIGHT := 25

var tmrScene: PackedScene

@onready var currentTimeFactor := 1.0

func _ready() -> void:
	tmrScene = preload("res://scenes/characters/timer_node.tscn")
	health = MAX_HEALTH

func CreateTimer(time: int, functi: Callable):
	var x = tmrScene.instantiate()
	x.time = time
	x.cb = functi 
	x.height = COUNTDOWN_HEIGHT
	add_child(x)
	x.global_position = global_position

func set_speed(mult: float) -> void:
	currentTimeFactor *= mult
