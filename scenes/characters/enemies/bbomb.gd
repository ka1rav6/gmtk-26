extends "res://scenes/characters/generic_enemy.gd"

const onHoverScaleFactor = 1.25
const slowDownTimeFactor = 0.1

func toggle_sprite() -> void:
	$select_sprite.visible = Global.powerMode

func _physics_process(delta: float) -> void:
	var tDelta = delta * currentTimeFactor
	var tSpeed = SPEED * currentTimeFactor
	var tJumpVelocity = JUMP_VELOCITY * sqrt(currentTimeFactor)
	if not is_on_floor():
		velocity += get_gravity() * tDelta 
	
	if is_on_wall() and is_on_floor():
		# velocity.y = JUMP_VELOCITY
		velocity.y = tJumpVelocity
	
	if Global.player:
		var direction :=  1 if ((Global.player.global_position.x - global_position.x) > 0) else -1
		if direction:
			velocity.x = direction * tSpeed
		else:
			velocity.x = move_toward(velocity.x, 0, tSpeed)
	#velocity *= currentTimeFactor
	
	move_and_slide()


func _on_mouse_collider_mouse_entered() -> void:
	$select_sprite.scale *= onHoverScaleFactor

func _on_mouse_collider_mouse_exited() -> void:
	$select_sprite.scale /= onHoverScaleFactor

func _tf() -> void:
	currentTimeFactor /= slowDownTimeFactor

func _on_mouse_collider_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			Global.toggle_all()
			currentTimeFactor *= slowDownTimeFactor
			CreateTimer(5, Callable(self, "_tf"))
