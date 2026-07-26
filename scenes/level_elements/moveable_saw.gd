extends Area2D


@export var anim_length := 3.0
@export var slowDownTimeFactor := 0.1
@export var onHoverScaleFactor := 1.25

@onready var animP: AnimationPlayer = $AnimationPlayer
@onready var from_point: Marker2D = $from_point
@onready var to_point: Marker2D = $to_point
@onready var sels: Sprite2D = $select_sprite
@onready var mc: Area2D = $mouseCollider

var currentTimeFactor := 1.0
var isAffectedBy := 0
var _freeze_timer: Timer = null


func _ready() -> void:
	add_to_group("selectable")
	mc.mouse_entered.connect(_on_mouse_collider_mouse_entered)
	mc.mouse_exited.connect(_on_mouse_collider_mouse_exited)
	_build_movement()
	if Global.powerMode:
		set_speed(Global.ULTRAINSTINCT_SLOWDOWN)
	toggle_sprite()


func _process(delta: float) -> void:
	$Sprite2D.rotation += 4.0 * delta * currentTimeFactor


func _build_movement() -> void:
	var anim := Animation.new()
	anim.resource_name = "saw_move"
	anim.length = anim_length
	anim.loop_mode = Animation.LOOP_PINGPONG

	var track_idx := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, NodePath(".:global_position"))
	anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_LINEAR)

	var from := from_point.global_position
	var to := to_point.global_position
	anim.track_insert_key(track_idx, 0.0, from)
	anim.track_insert_key(track_idx, anim_length, to)

	var lib := AnimationLibrary.new()
	lib.add_animation(&"saw_move", anim)
	animP.add_animation_library(&"move", lib)
	animP.play(&"move/saw_move")


func toggle_sprite() -> void:
	sels.visible = Global.powerMode


func set_speed(mult: float) -> void:
	currentTimeFactor *= mult
	animP.speed_scale = currentTimeFactor


func _on_mouse_collider_mouse_entered() -> void:
	sels.scale *= onHoverScaleFactor


func _on_mouse_collider_mouse_exited() -> void:
	sels.scale /= onHoverScaleFactor


func _on_mouse_collider_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if not Global.powerMode:
		return
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if isAffectedBy > 0:
				Global.toggle_all()
				_reset_freeze_timer()
				return
			Global.toggle_all()
			set_speed(slowDownTimeFactor)
			isAffectedBy += 1
			_start_freeze_timer()

func _start_freeze_timer() -> void:
	_freeze_timer = Timer.new()
	_freeze_timer.wait_time = Global.freeze_duration
	_freeze_timer.one_shot = true
	add_child(_freeze_timer)
	_freeze_timer.timeout.connect(func():
		if is_instance_valid(self):
			set_speed(1.0 / slowDownTimeFactor)
			isAffectedBy -= 1
	)
	_freeze_timer.start()

func _reset_freeze_timer() -> void:
	if _freeze_timer and is_instance_valid(_freeze_timer):
		_freeze_timer.stop()
		_freeze_timer.queue_free()
	_start_freeze_timer()


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1000000000000)
	else:
		body.queue_free()
