@tool
extends Node2D

# bullet-style tracer: shoots from the spawn point along `direction` until it
# hits world geometry (or runs out of `max_length`), then fades out.

@export var direction := Vector2.RIGHT
@export var max_length := 2000.0
# how long the beam takes to shoot out to its full length
@export var extend_time := 0.12
# how long it lingers and fades once fully extended
@export var fade_time := 0.35
@export var thickness := 4.0
@export var color := Color(1, 0.85, 0.4)
# world static only, so the ray ignores other enemies and the player
@export_flags_2d_physics var collision_mask := 2

var _length := 0.0
var _alpha := 1.0

func _ready() -> void:
	if Engine.is_editor_hint():
		# static preview so the node is visible while placing it
		_length = 200.0
		_alpha = 1.0
		queue_redraw()

func fire(dir: Vector2, exclude: Array[RID] = []) -> void:
	if dir == Vector2.ZERO:
		queue_free()
		return
	direction = dir.normalized()

	var target := _cast(exclude)
	var tw := create_tween()
	tw.tween_method(_set_length, 0.0, target, extend_time)\
		.set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tw.tween_method(_set_alpha, 1.0, 0.0, fade_time)
	tw.tween_callback(queue_free)

func _cast(exclude: Array[RID]) -> float:
	var space := get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(
		global_position, global_position + direction * max_length, collision_mask)
	params.exclude = exclude
	var hit := space.intersect_ray(params)
	if hit.is_empty():
		return max_length
	return global_position.distance_to(hit.position)

func _set_length(l: float) -> void:
	_length = l
	queue_redraw()

func _set_alpha(a: float) -> void:
	_alpha = a
	queue_redraw()

func _draw() -> void:
	if _length <= 0.0:
		return
	var tip := direction * _length
	# soft outer glow
	draw_line(Vector2.ZERO, tip, Color(color, _alpha * 0.25), thickness * 2.5, true)
	# bright core
	draw_line(Vector2.ZERO, tip, Color(color, _alpha), thickness, true)
	# muzzle + impact caps
	draw_circle(Vector2.ZERO, thickness * 0.7, Color(color, _alpha))
	draw_circle(tip, thickness * 0.9, Color(color, _alpha))
