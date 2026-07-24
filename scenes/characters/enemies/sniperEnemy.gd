extends "res://scenes/characters/generic_enemy.gd"

var pulseTimer: Timer
@onready var motionRayScene: PackedScene = preload("res://scenes/effects/motion_ray.tscn")

func _ready() -> void:
	super._ready()
	pulseTimer = Timer.new()
	pulseTimer.one_shot = true
	pulseTimer.timeout.connect(_on_pulse_timer_timeout)
	add_child(pulseTimer)
	_schedule_pulse()

func _schedule_pulse() -> void:
	pulseTimer.start(randi_range(3, 5))

func _on_pulse_timer_timeout() -> void:
	pulse()
	_schedule_pulse()

func _physics_process(delta: float) -> void:
	var tSpeed = SPEED * currentTimeFactor
	if isThrown:
		velocity.x = move_toward(velocity.x, 0, tSpeed)
	else:
		velocity.x = move_toward(velocity.x, 0, 2 * tSpeed)
		super._physics_process(delta)

func pulse() -> void:
	var w = motionRayScene.instantiate()
	add_child(w)
	w.global_position = global_position
	if not is_instance_valid(Global.player):
		return
	var dir = (Global.player.global_position - global_position).normalized()
	w.fire(dir, [get_rid()] as Array[RID])
