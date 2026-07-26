extends "res://scenes/characters/generic_enemy.gd"

enum State {
	IDLE,
	DASH,
	EXPLOSION
}

var state = State.IDLE

@export var dash_speed := 700.0
@export var explosion_dmg := 100

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var explosion_radius: Area2D = $Explosion_radius
@onready var detection_radius: Area2D = $Detection_radius
@onready var explosion_timer: Timer = $explode_time

func _ready() -> void:
	super._ready()
	detection_radius.body_entered.connect(_body_entered_detection_radius)
	explosion_timer.timeout.connect(explode)

func _body_entered_detection_radius(body: Node) -> void:
	if body != Global.player:
		return
	if state != State.IDLE:
		return
	state = State.DASH
	sprite.modulate = Color.CRIMSON
	explosion_timer.start()

func explode() -> void:
	if state == State.EXPLOSION:
		return
	state = State.EXPLOSION
	velocity = Vector2.ZERO

	# Snapshot targets before animation — don't rely on overlapping at end
	var targets: Array[Node2D] = []
	for body in explosion_radius.get_overlapping_bodies():
		if body != self and body.has_method("take_damage"):
			targets.append(body)

	sprite.play("explosion")
	await sprite.animation_finished

	for target in targets:
		if is_instance_valid(target):
			target.take_damage(explosion_dmg)

	_on_death()
	queue_free()

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0 and state != State.EXPLOSION:
		explode()

func _physics_process(delta: float) -> void:
	var tSpeed = SPEED * currentTimeFactor
	var tMaxVel = MAX_VELOCITY * currentTimeFactor
	var tDashSpeed = dash_speed * currentTimeFactor
	var tJumpVelocity = JUMP_VELOCITY * sqrt(currentTimeFactor)

	if is_on_wall() and is_on_floor():
		velocity.y = tJumpVelocity

	if Global.player and !isThrown:
		var direction := 1 if Global.player.global_position.x > global_position.x else -1
		match state:
			State.IDLE:
				velocity.x += direction * tSpeed
				if abs(velocity.x) > tMaxVel:
					velocity.x = tMaxVel * sign(velocity.x)
			State.DASH:
				velocity.x += direction * tDashSpeed
				if abs(velocity.x) > tMaxVel * 2.0:
					velocity.x = tMaxVel * 2.0 * sign(velocity.x)
			State.EXPLOSION:
				velocity = Vector2.ZERO

	if state != State.EXPLOSION:
		if sprite.animation != "idle":
			sprite.play("idle")
		sprite.rotation += velocity.x * delta / 10.0

	super._physics_process(delta)
