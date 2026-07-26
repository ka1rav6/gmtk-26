extends Area2D


@export var nextLevel: PackedScene
@export var enemies_required: int = 5

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label


func _ready() -> void:
	Global.kill_count = 0
	modulate = Color.RED
	col.set_deferred("disabled", true)
	label.text = "0 / %d" % enemies_required


func _process(_delta: float) -> void:
	label.text = "%d / %d" % [Global.kill_count, enemies_required]
	if Global.kill_count >= enemies_required:
		modulate = Color.WHITE
		col.set_deferred("disabled", false)
		label.visible = false
		set_process(false)


func _on_body_entered(body: Node2D) -> void:
	if body == Global.player:
		get_tree().call_deferred("change_scene_to_packed", nextLevel)
		Global.setup_level_timer_if_needed.call_deferred()
