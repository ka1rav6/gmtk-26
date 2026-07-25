extends "res://scenes/characters/generic_enemy.gd"

@onready var bullet_scene: PackedScene = preload("res://scenes/attack_mechanisms/bullet.tscn")
@onready var fire_timer: Timer
var can_fire := true

const FIRE_COOLDOWN := 1.0
const BULLET_DAMAGE := 20
const DIST_SQ_RANGE := 1000000.0
@export var bullet_slowdown := 0.1

func _ready() -> void:
	super._ready()
	fire_timer = Timer.new()
	fire_timer.one_shot = true
	fire_timer.timeout.connect(_on_fire_cooldown)
	add_child(fire_timer)

func _in_range() -> bool:
	if not is_instance_valid(Global.player):
		return false
	return global_position.distance_squared_to(Global.player.global_position) < DIST_SQ_RANGE

func _fire() -> void:
	can_fire = false
	fire_timer.start(FIRE_COOLDOWN)
	var b = bullet_scene.instantiate()
	get_parent().add_child(b)
	b.global_position = global_position
	b.direction = (Global.player.global_position - global_position).normalized()
	b.SPEED = MAX_VELOCITY * 1.5
	b.damage = BULLET_DAMAGE
	b.ignore_body = self
	b.slowDownTimeFactor = bullet_slowdown

func _on_fire_cooldown() -> void:
	can_fire = true

func _physics_process(delta: float) -> void:
	var tSpeed = SPEED * currentTimeFactor
	var tMaxVel = MAX_VELOCITY * currentTimeFactor
	var tJumpVelocity = JUMP_VELOCITY * sqrt(currentTimeFactor)

	if is_on_wall() and is_on_floor():
		velocity.y = tJumpVelocity

	if Global.player:
		if !isThrown:
			var direction := 1 if ((Global.player.global_position.x - global_position.x) > 0) else -1
			if direction:
				velocity.x += direction * tSpeed
			else:
				velocity.x = move_toward(velocity.x, 0, 2 * tSpeed)
			if abs(velocity.x) > tMaxVel:
				velocity.x = sign(velocity.x) * tMaxVel
		else:
			velocity.x = move_toward(velocity.x, 0, tSpeed)

	if Global.player and can_fire and _in_range():
		_fire()

	super._physics_process(delta)
