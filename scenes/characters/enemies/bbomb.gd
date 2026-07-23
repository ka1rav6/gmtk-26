extends "res://scenes/characters/generic_enemy.gd"




func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta 
	
	if is_on_wall() and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if player:
		var direction :=  1 if ((player.global_position.x - global_position.x) > 0) else -1
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	velocity *= currentTimeFactor
	
	print(velocity.length())
	
	move_and_slide()
