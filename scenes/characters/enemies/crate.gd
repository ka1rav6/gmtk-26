extends "res://scenes/characters/generic_enemy.gd"

func _ready():
	super._ready()
	Global.enemy_count += 1
	

func _on_death() -> void:
	# call this function when you kill it
	Global.enemy_count -= 1

func _exit_tree() -> void:
	pass
