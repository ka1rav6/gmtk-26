extends Area2D


@export var nextLevel: PackedScene
@export var enemies_required: int = 5

@onready var col: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	Global.kill_count = 0
	modulate = Color.RED
	col.set_deferred("disabled", true)


func _process(_delta: float) -> void:
	if Global.kill_count >= enemies_required:
		modulate = Color.WHITE
		col.set_deferred("disabled", false)
		set_process(false)


func _on_body_entered(body: Node2D) -> void:
	if body == Global.player:
		get_tree().change_scene_to_packed(nextLevel)
