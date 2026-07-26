extends CharacterBody2D

@export var on_duration := 3.0
@export var off_duration := 2.0
@export var beam_damage := 10
@export var beam_thickness := 8.0
@export var beam_color := Color(1.0, 0.2, 0.2)
@export var MAX_HEALTH := 25
@export var target: Node2D
@export var sels: Sprite2D
@export var mc: Area2D

@onready var tmrScene: PackedScene = preload("res://scenes/characters/timer_node.tscn")

var health: int
var currentTimeFactor := 1.0
var slowDownTimeFactor := 0.1
var is_grabbed := true # Prevents player from grabbing
var isAffectedBy := 0
var COUNTDOWN_HEIGHT := 60

var _enemy_dead := false
var _freeze_timer_node: Node = null

var _beam_active := false
var _cycle_time_remaining := 0.0
var _beam_length := 0.0
var _beam_hit_distance := 0.0
var _beam_direction := Vector2.RIGHT

func _ready() -> void:
	health = MAX_HEALTH
	Global.enemy_count += 1
	if is_instance_valid(mc):
		mc.mouse_entered.connect(func(): if is_instance_valid(sels): sels.scale *= 1.25)
		mc.mouse_exited.connect(func(): if is_instance_valid(sels): sels.scale /= 1.25)
		mc.input_event.connect(_on_mouse_input)
	_start_off_cycle()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0 and not _enemy_dead:
		_enemy_dead = true
		Global.kill_count += 1
		Global.enemy_count -= 1
		queue_free()

func _start_off_cycle() -> void:
	_beam_active = false
	_beam_length = 0.0
	queue_redraw()
	_cycle_time_remaining = off_duration

func _start_on_cycle() -> void:
	_beam_active = true
	_cycle_time_remaining = on_duration

func _on_beam_timer_timeout() -> void:
	if _beam_active: _start_off_cycle()
	else: _start_on_cycle()

func _cast_beam() -> void:
	if not is_instance_valid(target): return
	_beam_direction = (target.global_position - global_position).normalized()
	var space = get_world_2d().direct_space_state
	var params := PhysicsRayQueryParameters2D.create(
		global_position, global_position + _beam_direction * 2000.0, collision_mask | 1)
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

func _process(delta: float) -> void:
	_cycle_time_remaining -= delta * currentTimeFactor
	if _cycle_time_remaining <= 0.0:
		_on_beam_timer_timeout()
	if _beam_active:
		_cast_beam()

func _draw() -> void:
	if not _beam_active or _beam_length <= 0.0: return
	var tip := _beam_direction * _beam_length
	draw_line(Vector2.ZERO, tip, Color(beam_color, 0.3), beam_thickness * 2.5, true)
	draw_line(Vector2.ZERO, tip, beam_color, beam_thickness, true)
	draw_circle(Vector2.ZERO, beam_thickness * 0.7, beam_color)
	draw_circle(tip, beam_thickness * 0.9, beam_color)

func toggle_sprite() -> void:
	if is_instance_valid(sels):
		sels.visible = Global.powerMode

func set_speed(mult: float) -> void:
	currentTimeFactor *= mult
	if mult < 1.0:
		velocity *= mult

func CreateTimer(time: int, functi: Callable) -> Node:
	var x = tmrScene.instantiate()
	x.time = time
	x.cb = functi 
	x.height = COUNTDOWN_HEIGHT
	add_child(x)
	x.global_position = global_position
	return x

func _tf() -> void:
	if currentTimeFactor < 1.0:
		if Global.powerMode:
			currentTimeFactor = Global.ULTRAINSTINCT_SLOWDOWN
		else:
			currentTimeFactor = 1.0
	isAffectedBy -= 1

func _on_mouse_input(_vp: Node, event: InputEvent, _idx: int) -> void:
	if not Global.powerMode: return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if isAffectedBy > 0:
			Global.toggle_all()
			if _freeze_timer_node and is_instance_valid(_freeze_timer_node):
				_freeze_timer_node.queue_free()
			_freeze_timer_node = CreateTimer(Global.freeze_duration, Callable(self, "_tf"))
			return
		Global.toggle_all()
		set_speed(slowDownTimeFactor)
		isAffectedBy += 1
		_freeze_timer_node = CreateTimer(Global.freeze_duration, Callable(self, "_tf"))
