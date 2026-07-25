extends Area2D

@export var activation_value: int = 1

var _bodies: Dictionary = {}


func _ready() -> void:
	collision_layer = 0
	collision_mask = 9
	monitoring = true
	modulate = Color.WHITE


func _on_body_entered(body: Node2D) -> void:
	var id = body.get_instance_id()
	if id in _bodies:
		return
	_bodies[id] = body
	if _bodies.size() == 1:
		Global.kill_count += activation_value
	modulate = Color.GREEN


func _on_body_exited(body: Node2D) -> void:
	var id = body.get_instance_id()
	_bodies.erase(id)
	if _bodies.is_empty():
		Global.kill_count = maxi(Global.kill_count - activation_value, 0)
		modulate = Color.WHITE
