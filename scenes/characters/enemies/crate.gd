extends "res://scenes/characters/generic_enemy.gd"

@export var MAX_FALL_SPEED : int = 600

func _ready():
	super._ready()

func _physics_process(delta: float) -> void:
	if(velocity.y > currentTimeFactor * MAX_FALL_SPEED):
		velocity.y = MAX_FALL_SPEED * currentTimeFactor
	super._physics_process(delta)
