extends AnimatableBody2D


@export var slowDownTimeFactor := 0.1
@export var onHoverScaleFactor := 1.25
@export var anim_length := 3.0

@onready var animP: AnimationPlayer = $AnimationPlayer
@onready var sels: Sprite2D = $select_sprite
@onready var mc: Area2D = $mouseCollider
@onready var from_point: Marker2D = $from_point
@onready var to_point: Marker2D = $to_point

var currentTimeFactor := 1.0


func _ready() -> void:
	add_to_group("selectable")
	mc.input_event.connect(_on_mouse_collider_input_event)
	mc.mouse_entered.connect(_on_mouse_collider_mouse_entered)
	mc.mouse_exited.connect(_on_mouse_collider_mouse_exited)
	_build_animation()
	if Global.powerMode:
		set_speed(Global.ULTRAINSTINCT_SLOWDOWN)
	toggle_sprite()


func _build_animation() -> void:
	var anim := Animation.new()
	anim.resource_name = "platform_move"
	anim.length = anim_length
	anim.loop_mode = Animation.LOOP_PINGPONG

	var track_idx := anim.add_track(Animation.TYPE_VALUE)
	anim.track_set_path(track_idx, NodePath(".:position"))
	anim.track_set_interpolation_type(track_idx, Animation.INTERPOLATION_LINEAR)

	var from := from_point.position
	var to := to_point.position
	anim.track_insert_key(track_idx, 0.0, from)
	anim.track_insert_key(track_idx, anim_length, to)

	var lib := AnimationLibrary.new()
	lib.add_animation(&"platform_move", anim)
	lib.add_animation(&"RESET", anim)
	animP.add_animation_library(&"", lib)
	animP.play(&"platform_move")


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
			Global.toggle_all()
			set_speed(slowDownTimeFactor)
			get_tree().create_timer(5.0).timeout.connect(func():
				if is_instance_valid(self):
					set_speed(1.0 / slowDownTimeFactor)
			)
