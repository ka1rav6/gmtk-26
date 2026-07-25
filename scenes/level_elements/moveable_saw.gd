extends Area2D


@export var anim_length := 3.0

@onready var animP: AnimationPlayer = $AnimationPlayer
@onready var spinAnimP: AnimationPlayer = $SpinAnimationPlayer
@onready var from_point: Marker2D = $from_point
@onready var to_point: Marker2D = $to_point


func _ready() -> void:
	spinAnimP.play("saw_animation")
	_build_movement()


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


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1000000000000)
	else:
		body.queue_free()
