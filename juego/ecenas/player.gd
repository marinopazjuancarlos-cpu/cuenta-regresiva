extends CharacterBody2D

var direccion : Vector2

@export var speed := 50
@onready var agente:NavigationAgent2D = $NavigationAgent2D

func _ready() -> void:
	agente.target_position = direccion

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("click"):
		direccion = get_global_mouse_position()
		agente.set_pathfinding_algorithm(0)
		agente.target_position = direccion
func _physics_process(delta: float) -> void:
	if agente.is_target_reached():
		velocity = Vector2.ZERO
	else:
		var dir:= to_local(agente.get_next_path_position()).normalized()
		velocity = velocity.lerp(dir * speed, delta)
	move_and_slide()
