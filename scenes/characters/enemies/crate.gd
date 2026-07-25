extends "res://scenes/characters/generic_enemy.gd"

@export var MAX_FALL_SPEED : int = 200

func _ready():
	super._ready()
	Global.enemy_count += 1
	

func _on_death() -> void:
	# call this function when you kill it
	Global.enemy_count -= 1

func _exit_tree() -> void:
	pass

func _physics_process(delta: float) -> void:
	if(velocity.y > currentTimeFactor * MAX_FALL_SPEED):
		velocity.y = MAX_FALL_SPEED * currentTimeFactor
	super._physics_process(delta)
