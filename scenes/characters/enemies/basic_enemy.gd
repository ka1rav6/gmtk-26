extends "res://scenes/characters/generic_enemy.gd"


func _physics_process(delta: float) -> void:
	var tSpeed = SPEED * currentTimeFactor
	var tMaxVel = MAX_VELOCITY * currentTimeFactor
	var tJumpVelocity = JUMP_VELOCITY * sqrt(currentTimeFactor)
	
	if is_on_wall() and is_on_floor():
		velocity.y = tJumpVelocity
	
	if Global.player:
		if !isThrown:
			var direction :=  1 if ((Global.player.global_position.x - global_position.x) > 0) else -1
			if direction:
				velocity.x += direction * tSpeed
			else:
				velocity.x = move_toward(velocity.x, 0, 2 * tSpeed)
			if abs(velocity.x) > tMaxVel:
				velocity.x = sign(velocity.x) * tMaxVel
		else:
			velocity.x = move_toward(velocity.x, 0, tSpeed)
	
	# move and slide is called by super
	super._physics_process(delta)
