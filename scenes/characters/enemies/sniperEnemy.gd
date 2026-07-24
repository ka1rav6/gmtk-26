extends "res://scenes/characters/generic_enemy.gd"

@onready var motionRayScene: PackedScene = preload("res://scenes/effects/motion_ray.tscn")
@onready var animP: AnimationPlayer = $AnimationPlayer
@onready var crossHair: Sprite2D = $crosshair
@onready var sight: Line2D = $sight
@onready var playerPos:= Vector2.ZERO
var isShooting := false

func _ready() -> void:
	super._ready()
	animP.animation_finished.connect(_on_animation_player_animation_finished)
	animP.play("idle")
	crossHair.visible = false

func set_speed(mult: float) -> void:
	super.set_speed(mult)
	animP.speed_scale = currentTimeFactor

func _schedule_pulse() -> void:
	if (not is_instance_valid(Global.player)):
		return
	if (not isShooting) && (Global.player.global_position - global_position).length_squared() < 10000000.0:
		isShooting = true
		playerPos = Global.player.global_position
		crossHair.reparent(get_parent())
		crossHair.global_position = playerPos
		crossHair.visible = true
		sight.clear_points()
		sight.add_point(Vector2.ZERO)
		sight.add_point(to_local(crossHair.global_position))
		animP.play("shoot", 0.5, randf_range(0.75, 1.25))


func _physics_process(delta: float) -> void:
	_schedule_pulse()
	var tSpeed = SPEED * currentTimeFactor
	if isThrown:
		velocity.x = move_toward(velocity.x, 0, tSpeed)
	else:
		velocity.x = move_toward(velocity.x, 0, 2 * tSpeed)
	if velocity != Vector2.ZERO or !is_on_floor():
		sight.clear_points()
		sight.add_point(Vector2.ZERO)
		sight.add_point(to_local(crossHair.global_position))
		
	super._physics_process(delta)

func pulse() -> void:
	var w = motionRayScene.instantiate()
	add_child(w)
	w.global_position = global_position
	w.damage = 40
	w.damages_enemies = isAffectedBy > 0
	if playerPos == Vector2.ZERO:
		return
	var dir = (playerPos - global_position).normalized()
	w.fire(dir, [get_rid()] as Array[RID])
	sight.clear_points()


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "shoot":
		isShooting = false
		pulse()
		animP.play("idle")
		crossHair.visible = false
		crossHair.reparent(self)
