extends "res://scenes/characters/generic_enemy.gd"

# Chases the player on foot and swings a bat once it is close enough.
# Damage is one heart: the player has 100 HP and the HUD reads as 5 hearts,
# so a heart is 20 -- the same chunk a gunner bullet takes.
const ATTACK_DAMAGE := 15
const ATTACK_RANGE_SQ := 6400.0
const WINDUP_TIME := 0.25
const SWING_TIME := 0.15
const RECOVER_TIME := 0.7
# Bat angles, in radians, measured on the pivot: cocked back, then chopped down.
const REST_ANGLE := -0.7
const WINDUP_ANGLE := -1.6
const SWING_ANGLE := 1.2

enum State { CHASE, WINDUP, SWING, RECOVER }

@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var hitbox: Area2D = $WeaponPivot/Hitbox
@onready var hitbox_shape: CollisionShape2D = $WeaponPivot/Hitbox/CollisionShape2D

var _state := State.CHASE
var _state_time := 0.0
var _facing := 1
var _hit_this_swing := false

func _ready() -> void:
	super._ready()
	_set_hitbox_active(false)
	weapon_pivot.rotation = REST_ANGLE

func _on_death() -> void:
	Global.enemy_count -= 1

func _in_attack_range() -> bool:
	if not is_instance_valid(Global.player):
		return false
	return global_position.distance_squared_to(Global.player.global_position) < ATTACK_RANGE_SQ

# The shape is enabled a frame early (during the wind-up) so the physics server
# has already registered the overlap by the time the swing looks for a body.
func _set_hitbox_active(active: bool) -> void:
	hitbox.set_deferred("monitoring", active)
	hitbox_shape.set_deferred("disabled", not active)

func _try_hit() -> void:
	if _hit_this_swing:
		return
	for body in hitbox.get_overlapping_bodies():
		if body == self or not body.is_in_group("Player"):
			continue
		if body.has_method("take_damage"):
			body.take_damage(ATTACK_DAMAGE)
			_hit_this_swing = true
			return

# Everything here runs on tDelta so the slow-mo ability stretches the swing
# out the same way it stretches the walk cycle.
func _update_attack(tDelta: float) -> void:
	_state_time += tDelta
	match _state:
		State.CHASE:
			weapon_pivot.rotation = lerp_angle(weapon_pivot.rotation, REST_ANGLE, minf(tDelta * 8.0, 1.0))
			if _in_attack_range() and not isThrown and not is_grabbed:
				_state = State.WINDUP
				_state_time = 0.0
				_hit_this_swing = false
				_set_hitbox_active(true)
		State.WINDUP:
			weapon_pivot.rotation = lerp_angle(REST_ANGLE, WINDUP_ANGLE, minf(_state_time / WINDUP_TIME, 1.0))
			if _state_time >= WINDUP_TIME:
				_state = State.SWING
				_state_time = 0.0
		State.SWING:
			weapon_pivot.rotation = lerp_angle(WINDUP_ANGLE, SWING_ANGLE, minf(_state_time / SWING_TIME, 1.0))
			_try_hit()
			if _state_time >= SWING_TIME:
				_state = State.RECOVER
				_state_time = 0.0
				_set_hitbox_active(false)
		State.RECOVER:
			weapon_pivot.rotation = lerp_angle(SWING_ANGLE, REST_ANGLE, minf(_state_time / RECOVER_TIME, 1.0))
			if _state_time >= RECOVER_TIME:
				_state = State.CHASE
				_state_time = 0.0

func _physics_process(delta: float) -> void:
	var tDelta = delta * currentTimeFactor
	var tSpeed = SPEED * currentTimeFactor
	var tMaxVel = MAX_VELOCITY * currentTimeFactor
	var tJumpVelocity = JUMP_VELOCITY * sqrt(currentTimeFactor)

	if is_on_wall() and is_on_floor():
		velocity.y = tJumpVelocity

	if is_instance_valid(Global.player):
		if !isThrown:
			var direction := 1 if ((Global.player.global_position.x - global_position.x) > 0) else -1
			# Committed to a direction once the bat is already moving.
			if _state == State.CHASE:
				_facing = direction
				weapon_pivot.scale = Vector2(_facing, 1)
			# Plant your feet mid-swing instead of shoving the player around.
			if _state == State.CHASE or _state == State.RECOVER:
				velocity.x += direction * tSpeed
			else:
				velocity.x = move_toward(velocity.x, 0, 4 * tSpeed)
			if abs(velocity.x) > tMaxVel:
				velocity.x = sign(velocity.x) * tMaxVel

	_update_attack(tDelta)

	# move and slide is called by super
	super._physics_process(delta)
