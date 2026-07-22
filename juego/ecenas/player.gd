extends CharacterBody2D

var direccion : Vector2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		direccion = get_global_mouse_position()

func _physics_process(delta: float) -> void:
	var vel = (direccion - self.global_position)
	vel = vel.clamp(Vector2(-100,-100), Vector2(100,100))
	velocity = vel
	move_and_slide()
