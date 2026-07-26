extends Node2D

@onready var bar: ProgressBar = $ProgressBar

var enemy: Node2D

func _ready() -> void:
	bar.max_value = enemy.MAX_HEALTH if enemy and "MAX_HEALTH" in enemy else 1
	bar.value = enemy.health if enemy and "health" in enemy else 0
	bar.visible = false

func _process(_delta: float) -> void:
	if not is_instance_valid(enemy):
		queue_free()
		return
	bar.value = enemy.health
	bar.visible = enemy.health < enemy.MAX_HEALTH and enemy.health > 0
