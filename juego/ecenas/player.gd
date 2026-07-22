extends CharacterBody2D

var Destination = Vector2()
var Distance = Vector2()
var Velocity = Vector2()

@export var speed = 250.0

func _ready() -> void:
	Destination = position

func _physics_process(delta: float) -> void:
	if (position != Destination):
		Distance = Vector2(Destination - position)
		Velocity.x = Distance.normalized().x * speed
		Velocity.y = Distance.normalized().y * 0
		velocity = Velocity
		move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("click"):
		Destination = get_global_mouse_position()
