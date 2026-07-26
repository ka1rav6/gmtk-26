extends Area2D

@export var nextLevel : PackedScene

func _on_body_entered(body: Node2D) -> void:
	if body == Global.player:
		get_tree().call_deferred("change_scene_to_packed", nextLevel)
		Global.setup_level_timer_if_needed.call_deferred()
