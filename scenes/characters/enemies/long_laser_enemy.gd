extends "res://scenes/characters/generic_enemy.gd"

@export var on_duration := 3.0
@export var off_duration := 2.0
@export var beam_damage := 10
@export var beam_thickness := 8.0
@export var beam_color := Color(1.0, 0.2, 0.2)
@export var target: Node2D

var _beam_active := false
var _beam_timer: Timer
var _beam_length := 0.0
var _beam_hit_distance := 0.0
var _beam_direction := Vector2.RIGHT

func _ready() -> void:
	super._ready()
	_beam_timer = Timer.new()
	_beam_timer.one_shot = true
	_beam_timer.timeout.connect(_on_beam_timer_timeout)
	add_child(_beam_timer)
	_start_off_cycle()

func _start_off_cycle() -> void:
	_beam_active = false
	_beam_length = 0.0
	queue_redraw()
	_beam_timer.start(off_duration)

func _start_on_cycle() -> void:
	_beam_active = true
	_beam_timer.start(on_duration)

func _on_beam_timer_timeout() -> void:
	if _beam_active:
		_start_off_cycle()
	else:
		_start_on_cycle()

func _cast_beam() -> void:
	if not is_instance_valid(target):
		return
	_beam_direction = (target.global_position - global_position).normalized()
	var space = get_world_2d().direct_space_state
	var mask := collision_mask | 1
	var params := PhysicsRayQueryParameters2D.create(
		global_position, global_position + _beam_direction * 2000.0, mask)
	params.exclude = [get_rid()]
	var hit := space.intersect_ray(params)
	if hit.is_empty():
		_beam_hit_distance = 2000.0
	else:
		_beam_hit_distance = global_position.distance_to(hit.position)
		if hit.collider.has_method("take_damage"):
			hit.collider.take_damage(beam_damage)
	_beam_length = _beam_hit_distance
	queue_redraw()

func _process(_delta: float) -> void:
	if _beam_active:
		_cast_beam()

func _draw() -> void:
	if not _beam_active or _beam_length <= 0.0:
		return
	var tip := _beam_direction * _beam_length
	draw_line(Vector2.ZERO, tip, Color(beam_color, 0.3), beam_thickness * 2.5, true)
	draw_line(Vector2.ZERO, tip, beam_color, beam_thickness, true)
	draw_circle(Vector2.ZERO, beam_thickness * 0.7, beam_color)
	draw_circle(tip, beam_thickness * 0.9, beam_color)

func _physics_process(_delta: float) -> void:
	pass
