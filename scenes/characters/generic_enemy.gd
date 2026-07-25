extends CharacterBody2D


@export var SPEED = 5.0
@export var JUMP_VELOCITY = -400.0
@export var MAX_HEALTH := 25
@export var MAX_VELOCITY := 80.0
@export var COUNTDOWN_HEIGHT := 60
@export var onHoverScaleFactor = 1.25
@export var slowDownTimeFactor = 0.1
@export var power := 8.0
@export var max_drag := 200.0
@export var line : Line2D = null
@export var sels : Sprite2D = null
@export var mc : Area2D = null

@onready var tmrScene: PackedScene = preload("res://scenes/characters/timer_node.tscn")
@onready var health:= MAX_HEALTH

var currentTimeFactor := 1.0
var dragging := false
var drag_start := Vector2.ZERO
var drag_current := Vector2.ZERO

var isAffectedBy := 0
var isThrown := false

func _ready() -> void:
	Global.enemy_count += 1
	set_physics_process(false)
	if line == null:
		line = $ShootDir
	if sels == null:
		sels = $select_sprite
	if mc == null:
		mc = $mouseCollider
	mc.input_event.connect(_on_mouse_collider_input_event)
	mc.mouse_entered.connect(_on_mouse_collider_mouse_entered)
	mc.mouse_exited.connect(_on_mouse_collider_mouse_exited)


func toggle_sprite() -> void:
	sels.visible = Global.powerMode

func CreateTimer(time: int, functi: Callable):
	var x = tmrScene.instantiate()
	x.time = time
	x.cb = functi 
	x.height = COUNTDOWN_HEIGHT
	add_child(x)
	x.global_position = global_position

func set_speed(mult: float) -> void:
	currentTimeFactor *= mult
	velocity *= mult

func _on_death() -> void:
	Global.enemy_count -= 1
	

func _on_mouse_collider_mouse_entered() -> void:
	sels.scale *= onHoverScaleFactor

func _on_mouse_collider_mouse_exited() -> void:
	sels.scale /= onHoverScaleFactor

func _tf() -> void:
	if currentTimeFactor < 1.0:
		set_speed(1 / slowDownTimeFactor)
	isAffectedBy -= 1
	if dragging:
		dragging = false
		Global.toggle_all()
		mc.scale /= 20.0
		line.clear_points()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		_on_death()
		queue_free()

func throw() -> void:
	var drag = global_position - get_global_mouse_position()
	if drag.length() > max_drag:
		drag = drag.normalized() * max_drag
	var throw_power = power
	if currentTimeFactor >= 1.0:
		throw_power *= (1.0 / Global.ULTRAINSTINCT_SLOWDOWN)
	velocity += drag * throw_power
	currentTimeFactor = 1.0
	move_and_slide()
	isThrown = true
	set_physics_process(true)

func update_trajectory() -> void:
	line.clear_points()
	var drag = global_position - get_global_mouse_position()
	if drag.length() > max_drag:
		drag = drag.normalized() * max_drag
	var vel2 = (velocity + drag * power) * (1.0 / Global.ULTRAINSTINCT_SLOWDOWN)

	var simpos = Vector2.ZERO
	var step_dt = 0.25

	for i in range(15):
		line.add_point(simpos)
		vel2 += get_gravity() * step_dt
		simpos += vel2 * step_dt

func _on_mouse_collider_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not Global.powerMode:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Global.toggle_all()
			set_speed(slowDownTimeFactor)
			isAffectedBy += 1
			CreateTimer(5, Callable(self, "_tf"))
		elif event.button_index == MOUSE_BUTTON_RIGHT and (Global.player.global_position - global_position).length_squared() < (Global.throwDistance**2):
			if event.is_released() and dragging:
				Global.toggle_all()
				throw()
				mc.scale /= 20.0
				dragging = false
				line.clear_points()
			elif event.pressed:
				if global_position.distance_squared_to(get_global_mouse_position()) < 576:
					mc.scale *= 20.0
					dragging = true
		else:
			if (not Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT)) and (dragging or line.points.size() > 0):
				line.clear_points()
	elif event is InputEventMouseMotion and dragging:
		update_trajectory()

func _physics_process(delta: float) -> void:
	var tDelta = delta * currentTimeFactor
	if not is_on_floor():
		velocity += get_gravity() * tDelta 
	if isThrown && (is_on_ceiling() || is_on_floor() || is_on_wall()):
		isThrown = false
	move_and_slide()
