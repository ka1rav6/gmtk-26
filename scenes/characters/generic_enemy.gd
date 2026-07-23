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
var isAffectedBy := 0
var dragging := false
var drag_start := Vector2.ZERO
var drag_current := Vector2.ZERO

func _ready() -> void:
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

func _on_mouse_collider_mouse_entered() -> void:
	sels.scale *= onHoverScaleFactor

func _on_mouse_collider_mouse_exited() -> void:
	sels.scale /= onHoverScaleFactor

func _tf() -> void:
	currentTimeFactor /= slowDownTimeFactor
	isAffectedBy -= 1

func shoot() -> void:
	var drag = global_position - get_global_mouse_position()
	if drag.length() > max_drag:
		drag = drag.normalized() * max_drag
	velocity += drag * power

func update_trajectory() -> void:
	line.clear_points()
	var drag = global_position - get_global_mouse_position()
	if drag.length() > max_drag:
		drag = drag.normalized() * max_drag
	var vel2 = velocity + drag * power
	
	var simpos = Vector2.ZERO
	#var simvel = vel2
	var step_dt = 0.08
	
	for i in range(30):
		line.add_point(simpos)
		vel2 += get_gravity() * currentTimeFactor * step_dt / Global.ULTRAINSTINCT_SLOWDOWN
		simpos += vel2 * step_dt
	pass

func _on_mouse_collider_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not Global.powerMode:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Global.toggle_all()
			currentTimeFactor *= slowDownTimeFactor
			isAffectedBy += 1
			CreateTimer(5, Callable(self, "_tf"))
		elif event.button_index == MOUSE_BUTTON_RIGHT and isAffectedBy > 0:
			if event.is_released() and dragging:
				Global.toggle_all()
				shoot()
				mc.scale /= 20.0
				dragging = false
				line.clear_points()
			elif event.pressed:
				if global_position.distance_squared_to(get_global_mouse_position()) < 576:
					mc.scale *= 20.0
					dragging = true
	elif event is InputEventMouseMotion and dragging:
		update_trajectory()

func _physics_process(delta: float) -> void:
	var tDelta = delta * currentTimeFactor
	if not is_on_floor():
		velocity += get_gravity() * tDelta 
	
	move_and_slide()
